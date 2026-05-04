"""
AI Chatbot Service – RAG Pipeline
Uses ChromaDB as vector store + Google Gemini as LLM.
Legal knowledge base: Employment Act 1955, Industrial Relations Act 1967.
"""

import os
from fastapi import APIRouter
from pydantic import BaseModel, Field
import google.generativeai as genai
import chromadb
from chromadb.utils import embedding_functions

from config import get_settings

router = APIRouter()
settings = get_settings()

# ── Lazy-loaded singletons ────────────────────────────────────
_chroma_client = None
_collection = None
_gemini_model = None


def _get_chroma():
    global _chroma_client, _collection
    if _chroma_client is None:
        _chroma_client = chromadb.PersistentClient(path=settings.chroma_persist_dir)
        ef = embedding_functions.SentenceTransformerEmbeddingFunction(
            model_name="all-MiniLM-L6-v2"
        )
        _collection = _chroma_client.get_or_create_collection(
            name=settings.chroma_collection,
            embedding_function=ef,
        )
    return _collection


def _get_gemini():
    global _gemini_model
    if _gemini_model is None:
        genai.configure(api_key=settings.gemini_api_key)
        _gemini_model = genai.GenerativeModel("gemini-1.5-flash")
    return _gemini_model


# ── Schemas ───────────────────────────────────────────────────

class ChatRequest(BaseModel):
    query: str = Field(..., min_length=1, max_length=1000)
    session_id: str | None = None
    module: str = Field(default="labour_rights",
                        pattern="^(labour_rights|negotiation_coach|contract_review)$")
    history: list[dict] = Field(default_factory=list)


class Source(BaseModel):
    title: str
    section: str


class ChatResponse(BaseModel):
    answer: str
    sources: list[Source]
    module: str


class ContractRequest(BaseModel):
    clause: str = Field(..., min_length=10, max_length=2000)


# ── RAG helpers ───────────────────────────────────────────────

_SYSTEM_PROMPT = """You are WageWise AI, a legal assistant specialised in Malaysian
employment law. You help fresh graduates understand their rights under:
- Employment Act 1955 (EA 1955)
- Industrial Relations Act 1967 (IRA 1967)
- EPF Act 1991
- SOCSO Act 1969
- Minimum Wages Order 2022 (RM 1,700 from Feb 2025)

Rules:
1. Only answer based on the provided context. If context is insufficient, say so.
2. Always cite specific sections (e.g., "Section 60A, EA 1955").
3. Use plain, friendly language accessible to fresh graduates.
4. Never provide personal legal advice; recommend seeking a lawyer for complex cases.
5. Respond in the same language the user used (BM, EN, ZH, or TA)."""

_NEGOTIATION_PROMPT = """You are a salary negotiation coach for Malaysian fresh graduates.
Your role is to:
1. Play the HR/employer role in negotiation scenarios.
2. After each user response, provide structured feedback:
   - Strength: what they did well
   - Improve: what could be stronger
   - Malaysian tip: cultural nuance for local workplace
3. Use realistic Malaysian salary figures (RM 1,700–8,000 range).
4. Keep scenarios grounded in Malaysian workplace culture."""


def _retrieve_context(query: str, n_results: int = 5) -> tuple[str, list[Source]]:
    try:
        collection = _get_chroma()
        results = collection.query(query_texts=[query], n_results=n_results)
        docs = results.get("documents", [[]])[0]
        metas = results.get("metadatas", [[]])[0]

        context = "\n\n".join(docs) if docs else ""
        sources = [
            Source(
                title=m.get("title", "Employment Act 1955"),
                section=m.get("section", ""),
            )
            for m in metas
        ]
        return context, sources
    except Exception:
        return "", []


# ── Routes ────────────────────────────────────────────────────

@router.post("", response_model=ChatResponse)
async def chat(req: ChatRequest):
    model = _get_gemini()

    if req.module == "labour_rights":
        context, sources = _retrieve_context(req.query)
        prompt = (
            f"{_SYSTEM_PROMPT}\n\n"
            f"Context from legal documents:\n{context or 'No specific context found.'}\n\n"
            f"User question: {req.query}"
        )
    elif req.module == "negotiation_coach":
        context, sources = "", []
        history_text = "\n".join(
            f"{m['role'].upper()}: {m['content']}" for m in req.history
        )
        prompt = (
            f"{_NEGOTIATION_PROMPT}\n\n"
            f"Conversation so far:\n{history_text}\n\n"
            f"User: {req.query}"
        )
    else:  # contract_review
        context, sources = _retrieve_context(req.query)
        prompt = (
            f"{_SYSTEM_PROMPT}\n\n"
            "The user has submitted an employment contract clause for review.\n"
            f"Context:\n{context or 'No specific context.'}\n\n"
            f"Contract clause: {req.query}\n\n"
            "Identify any potential violations of Malaysian employment law. "
            "If compliant, confirm and explain why."
        )

    try:
        response = model.generate_content(prompt)
        answer = response.text
    except Exception as exc:
        answer = (
            "I'm unable to generate a response at the moment. "
            f"Please try again later. (Error: {exc})"
        )

    return ChatResponse(answer=answer, sources=sources, module=req.module)


@router.post("/contract", response_model=ChatResponse)
async def analyse_contract(req: ContractRequest):
    return await chat(
        ChatRequest(
            query=req.clause,
            module="contract_review",
        )
    )
