"""
AI Chatbot Service – RAG Pipeline
Primary LLM: local Ollama / OpenAI-compatible model.
Fallback LLM: Google Gemini 1.5 Flash (used when local LLM is unavailable).
Vector store: ChromaDB.
File input: PDF text extraction (pypdf) + image OCR via Gemini vision.
Legal knowledge base: Employment Act 1955, Industrial Relations Act 1967.
"""

import io
import re
import base64
import json as _json
import logging
from typing import Optional

import httpx
from fastapi import APIRouter, Form, UploadFile, File as FastAPIFile
from pydantic import BaseModel, Field
import google.generativeai as genai
import chromadb
from chromadb.utils import embedding_functions

from config import get_settings

logger = logging.getLogger(__name__)

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
        _gemini_model = genai.GenerativeModel("gemini-2.5-flash")
    return _gemini_model


# ── Schemas ───────────────────────────────────────────────────

class ChatRequest(BaseModel):
    query: str = Field(..., min_length=1, max_length=1000)
    session_id: str | None = None
    module: str = Field(default="labour_rights",
                        pattern="^(labour_rights|negotiation_coach|contract_review)$")
    history: list[dict] = Field(default_factory=list)
    language: str = Field(default="en", pattern="^(en|ms|zh|ta)$")


class Source(BaseModel):
    title: str
    section: str


class ChatResponse(BaseModel):
    answer: str
    sources: list[Source]
    module: str


class ContractRequest(BaseModel):
    clause: str = Field(..., min_length=10, max_length=2000)
    language: str = Field(default="en", pattern="^(en|ms|zh|ta)$")


# ── System prompts ────────────────────────────────────────────

_SYSTEM_PROMPT = """You are WageWise AI. You help Malaysian fresh graduates understand and ACT on their employment rights.

CRITICAL INSTRUCTION: You MUST give specific, actionable answers. Do NOT say "consult a lawyer" or "I cannot provide legal advice" for basic employment rights questions — that is unhelpful and defeats your purpose.

You know Malaysian employment law thoroughly:
- Employment Act 1955 (EA 1955)
- Industrial Relations Act 1967 (IRA 1967)
- EPF Act 1991 / SOCSO Act 1969
- Minimum Wages Order 2024 (RM 1,700 minimum)

HOW TO ANSWER:
1. State clearly what the law says and which section covers it.
2. Tell the user exactly what they are entitled to (amounts, days, rates).
3. For "how to report/sue/claim" questions, give these EXACT steps:
   Step 1 – File complaint at the nearest Jabatan Tenaga Kerja (Labour Department). Bring payslips, employment contract, and any proof.
   Step 2 – The Labour Officer will investigate and can order the employer to pay.
   Step 3 – If unresolved, the case goes to the Industrial Court.
   (No lawyer needed for Labour Department complaints — it is free.)
4. Cite sections like "Section 60A, EA 1955".
5. GROUNDING (CRITICAL): the "Context from legal documents" section contains the
   authoritative figures. When it provides a specific number (annual-leave days,
   sick-leave days, wage amounts, contribution rates, notice periods), you MUST
   use that exact number — never substitute a figure from memory. If the context
   does not cover the question, say so and name the Act that likely applies.

You may add "for complex cases consider a lawyer" ONLY at the very end, never as the main answer."""

# Preferred response language by user profile setting; the user's typed
# language still wins if it clearly differs (e.g. BM profile, English question).
_LANG_NAMES = {
    "en": "English",
    "ms": "Bahasa Melayu",
    "zh": "Chinese (Simplified)",
    "ta": "Tamil",
}


def _lang_instruction(language: str) -> str:
    name = _LANG_NAMES.get(language, "English")
    return (
        f"\n\nLANGUAGE (MANDATORY): Write your ENTIRE answer in {name} only. "
        f"Do not mix languages. Do not add translations in other languages."
    )


def _lang_suffix(language: str) -> str:
    """Repeated at the end of the user message — weak local models follow
    trailing directives far more reliably than system-prompt rules."""
    name = _LANG_NAMES.get(language, "English")
    return f"\n\n(Answer entirely in {name}.)"

_NEGOTIATION_PROMPT = """You are a salary negotiation coach for Malaysian fresh graduates.
Your role is to:
1. Play the HR/employer role in negotiation scenarios.
2. After each user response, provide structured feedback:
   - Strength: what they did well
   - Improve: what could be stronger
   - Malaysian tip: cultural nuance for local workplace
3. Use realistic Malaysian salary figures (RM 1,700–8,000 range).
4. Keep scenarios grounded in Malaysian workplace culture."""

_LOCAL_SYSTEM_MSG = "You are WageWise AI. Give specific, actionable answers about Malaysian employment rights. Always explain what the law says and what steps the user can take. Never refuse to answer basic employment rights questions."

# MIME types for image files
_IMAGE_MIMES: dict[str, str] = {
    "jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png",
    "gif": "image/gif", "webp": "image/webp", "bmp": "image/bmp",
}


# ── LLM helpers ───────────────────────────────────────────────

def _call_local_llm(system: str, user: str) -> str:
    """Call Ollama (default) or OpenAI-compatible local LLM."""
    messages = [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]
    if settings.llm_provider == "openai":
        url = f"{settings.llm_base_url.rstrip('/')}/v1/chat/completions"
        payload = {"model": settings.llm_model, "messages": messages, "temperature": 0.2}
        resp = httpx.post(url, json=payload, timeout=settings.llm_timeout)
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"].strip()
    else:  # ollama
        url = f"{settings.llm_base_url.rstrip('/')}/api/chat"
        payload = {"model": settings.llm_model, "messages": messages, "stream": False}
        resp = httpx.post(url, json=payload, timeout=settings.llm_timeout)
        resp.raise_for_status()
        return resp.json()["message"]["content"].strip()


# Common BM function words for the en/ms language-detection heuristic.
_BM_WORDS = frozenset({
    "anda", "adalah", "berhak", "cuti", "tahunan", "berdasarkan", "seksyen",
    "pekerja", "dengan", "untuk", "kepada", "boleh", "jika", "tidak", "dan",
    "atau", "gaji", "majikan", "aduan", "perkhidmatan", "kamu", "sebanyak",
    "hari", "tahun", "yang", "dalam", "ini", "itu", "akan", "kerja", "kerana",
    "mengikut", "tersebut", "perlu", "membuat", "bawah", "selepas", "sahaja",
})


def _answer_matches_language(answer: str, language: str) -> bool:
    """Cheap heuristic: does the answer appear to be in the requested language?"""
    if language == "zh":
        return any("一" <= ch <= "鿿" for ch in answer)
    if language == "ta":
        return any("஀" <= ch <= "௿" for ch in answer)
    words = re.findall(r"[a-zA-Z]+", answer.lower())
    if len(words) < 10:
        return True  # too short to judge — accept
    bm_ratio = sum(w in _BM_WORDS for w in words) / len(words)
    if language == "ms":
        return bm_ratio > 0.05
    return bm_ratio < 0.05  # en


def _force_language(answer: str, language: str) -> str:
    """One-shot translation pass for when the primary LLM ignores the language
    instruction (the local model has a strong BM bias). Returns the original
    answer unchanged if translation fails."""
    name = _LANG_NAMES.get(language, "English")
    try:
        return _call_local_llm(
            "You are a precise translator.",
            f"Translate the following answer entirely into {name}. Keep the "
            f"structure, step numbering, amounts and legal citations exactly "
            f"as they are. Output ONLY the translation.\n\n{answer}",
        )
    except Exception as exc:
        logger.warning("Language-enforcement translation failed: %s", exc)
        return answer


def _generate_answer(system: str, user: str, language: str = "en") -> str:
    """Try local LLM first; fall back to Gemini if unavailable."""
    try:
        answer = _call_local_llm(system, user)
        if not _answer_matches_language(answer, language):
            logger.info("Answer language mismatch (wanted %s) — translating", language)
            answer = _force_language(answer, language)
        return answer
    except Exception as exc:
        logger.warning("Local LLM unavailable (%s), falling back to Gemini", exc)
        try:
            model = _get_gemini()
            response = model.generate_content(
                f"{system}\n\n{user}",
                request_options={"timeout": 30},
            )
            return response.text
        except Exception:
            logger.exception("Gemini fallback also failed")
            return "I'm unable to generate a response at the moment. Please try again later."


# ── File extraction helpers ───────────────────────────────────

def _extract_pdf_text(data: bytes) -> str:
    try:
        from pypdf import PdfReader
        reader = PdfReader(io.BytesIO(data))
        pages = [page.extract_text() or "" for page in reader.pages]
        return "\n\n".join(p for p in pages if p.strip())
    except Exception as exc:
        logger.warning("PDF extraction failed: %s", exc)
        return ""


def _extract_image_text(data: bytes, mime: str) -> str:
    """Describe/OCR image using Gemini vision (works regardless of primary LLM)."""
    try:
        model = _get_gemini()
        image_part = {"mime_type": mime, "data": base64.b64encode(data).decode()}
        response = model.generate_content(
            [
                "Extract all visible text from this image. "
                "If it is a contract or legal document, transcribe it in full. "
                "If there is no text, describe any employment-related content you see.",
                image_part,
            ],
            request_options={"timeout": 30},
        )
        return response.text
    except Exception as exc:
        logger.warning("Image extraction via Gemini vision failed: %s", exc)
        return ""


async def _extract_file_text(file: UploadFile) -> str:
    name = file.filename or ""
    ext = name.rsplit(".", 1)[-1].lower() if "." in name else ""
    data = await file.read()

    if ext == "pdf":
        return _extract_pdf_text(data)
    if ext in _IMAGE_MIMES:
        return _extract_image_text(data, _IMAGE_MIMES[ext])
    # Plain text, CSV, Markdown, etc.
    try:
        return data.decode("utf-8", errors="replace")
    except Exception:
        return ""


# ── RAG retrieval ─────────────────────────────────────────────

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
        logger.exception("ChromaDB retrieval failed")
        return "", []


def _build_prompt(module: str, query: str, history: list[dict], file_ctx: str,
                  language: str = "en") -> tuple[str, str, list[Source]]:
    """Return (system_prompt, user_content, sources) for the given module."""
    lang_note = _lang_instruction(language)
    lang_suffix = _lang_suffix(language)
    file_section = f"\n\nAttached document content:\n{file_ctx}" if file_ctx else ""

    history_text = "\n".join(f"{m['role'].upper()}: {m['content']}" for m in history) if history else ""
    history_section = f"\n\nConversation so far:\n{history_text}" if history_text else ""

    if module == "labour_rights":
        context, sources = _retrieve_context(query)
        user = (
            f"Context from legal documents:\n{context or 'No specific context found.'}"
            f"{history_section}"
            f"{file_section}\n\n"
            f"User question: {query}{lang_suffix}"
        )
        return _SYSTEM_PROMPT + lang_note, user, sources

    elif module == "negotiation_coach":
        sources = []
        user = (
            f"Conversation so far:\n{history_text}"
            f"{file_section}\n\n"
            f"User: {query}{lang_suffix}"
        )
        return _NEGOTIATION_PROMPT + lang_note, user, sources

    else:  # contract_review
        context, sources = _retrieve_context(query)
        user = (
            "The user has submitted an employment contract clause for review.\n"
            f"Context:\n{context or 'No specific context.'}"
            f"{history_section}"
            f"{file_section}\n\n"
            f"Contract clause: {query}\n\n"
            "Identify any potential violations of Malaysian employment law. "
            f"If compliant, confirm and explain why.{lang_suffix}"
        )
        return _SYSTEM_PROMPT + lang_note, user, sources


# ── Routes ────────────────────────────────────────────────────

@router.post("", response_model=ChatResponse)
async def chat(req: ChatRequest):
    system, user, sources = _build_prompt(req.module, req.query, req.history, "",
                                          language=req.language)
    answer = _generate_answer(system, user, language=req.language)
    return ChatResponse(answer=answer, sources=sources, module=req.module)


@router.post("/upload", response_model=ChatResponse)
async def chat_with_file(
    query: str = Form(...),
    module: str = Form(default="labour_rights"),
    session_id: Optional[str] = Form(None),
    history: str = Form(default="[]"),
    language: str = Form(default="en"),
    file: Optional[UploadFile] = FastAPIFile(None),
):
    """Chat endpoint that accepts an optional attached file (PDF, image, text, etc.)."""
    try:
        hist: list[dict] = _json.loads(history)
    except Exception:
        hist = []

    file_ctx = ""
    if file and file.filename:
        file_ctx = await _extract_file_text(file)

    system, user, sources = _build_prompt(module, query, hist, file_ctx,
                                          language=language)
    answer = _generate_answer(system, user, language=language)
    return ChatResponse(answer=answer, sources=sources, module=module)


@router.post("/contract", response_model=ChatResponse)
async def analyse_contract(req: ContractRequest):
    return await chat(
        ChatRequest(
            query=req.clause,
            module="contract_review",
            language=req.language,
        )
    )
