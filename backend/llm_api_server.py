"""
Malaysian Employment Assistant - FastAPI Server

Provides REST API endpoints for the Flutter mobile app to interact
with the local LLM-based Malaysian employment law assistant.
"""

import os
import json
import secrets
import logging
from datetime import datetime
from typing import List, Optional

from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Load environment variables if python-dotenv is available
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# ============================================================================
# LOGGING
# ============================================================================

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ============================================================================
# APP INITIALIZATION
# ============================================================================

app = FastAPI(
    title="Malaysian Employment Assistant API",
    description="AI-powered Malaysian employment law assistant using a local LLM",
    version="1.0.0",
)

# CORS — allow all origins so the Flutter app can connect from any IP
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================================
# API KEY MANAGEMENT
# ============================================================================

API_KEYS_FILE = os.getenv("API_KEYS_FILE", "api_keys.json")


def load_api_keys() -> dict:
    """Load API keys from the JSON file."""
    if not os.path.exists(API_KEYS_FILE):
        return {}
    with open(API_KEYS_FILE, "r") as f:
        return json.load(f)


def save_api_keys(keys: dict) -> None:
    """Persist API keys to the JSON file."""
    with open(API_KEYS_FILE, "w") as f:
        json.dump(keys, f, indent=2)


def validate_api_key(x_api_key: str = Header(...)) -> str:
    """Dependency that validates the X-API-Key header."""
    api_keys = load_api_keys()
    if x_api_key not in api_keys:
        raise HTTPException(status_code=401, detail="Invalid API key")
    key_data = api_keys[x_api_key]
    if not key_data.get("active", False):
        raise HTTPException(status_code=401, detail="API key is inactive")
    # Update usage statistics
    api_keys[x_api_key]["last_used"] = datetime.now().isoformat()
    api_keys[x_api_key]["request_count"] = key_data.get("request_count", 0) + 1
    save_api_keys(api_keys)
    return x_api_key


def validate_admin_key(x_admin_key: str = Header(...)) -> str:
    """Dependency that validates the X-Admin-Key header for admin endpoints.

    The expected key is set via the ADMIN_API_KEY environment variable.
    When no ADMIN_API_KEY is configured the endpoint is open (development mode).
    """
    admin_key = os.getenv("ADMIN_API_KEY", "")
    if admin_key and x_admin_key != admin_key:
        raise HTTPException(status_code=401, detail="Invalid admin key")
    return x_admin_key


# ============================================================================
# LLM ASSISTANT — LAZY INITIALIZATION
# ============================================================================

_assistant = None


def get_assistant():
    """Return the singleton LLM assistant, initializing it on first call."""
    global _assistant
    if _assistant is None:
        from local_llm_malaysian_assistant import LocalMalaysianAssistant
        model_name = os.getenv("MODEL_NAME", "microsoft/Phi-3-mini-4k-instruct")
        use_quantization = os.getenv("USE_QUANTIZATION", "true").lower() == "true"
        logger.info("Initializing LLM assistant with model: %s", model_name)
        _assistant = LocalMalaysianAssistant(
            model_name=model_name,
            use_quantization=use_quantization,
        )
        logger.info("LLM assistant ready")
    return _assistant


# ============================================================================
# REQUEST / RESPONSE MODELS
# ============================================================================

class ChatRequest(BaseModel):
    message: str
    # conversation_history is accepted for forward-compatibility but the
    # current LocalMalaysianAssistant.chat() interface takes a single message.
    conversation_history: Optional[List[dict]] = []


class ChatResponse(BaseModel):
    response: str
    timestamp: str


class GenerateKeyRequest(BaseModel):
    name: str
    description: Optional[str] = ""


class GenerateKeyResponse(BaseModel):
    api_key: str
    name: str
    created_at: str


# ============================================================================
# ENDPOINTS
# ============================================================================

@app.get("/health")
async def health_check():
    """Health check — returns server status and whether the model is loaded."""
    return {
        "status": "healthy",
        "model_loaded": _assistant is not None,
        "timestamp": datetime.now().isoformat(),
    }


@app.post("/api/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    api_key: str = Depends(validate_api_key),
):
    """Send a message and receive a response from the employment assistant."""
    try:
        assistant = get_assistant()
        response = assistant.chat(request.message)
        return ChatResponse(
            response=response,
            timestamp=datetime.now().isoformat(),
        )
    except Exception as e:
        logger.error("Error processing chat request: %s", e)
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")


@app.post("/admin/generate-key", response_model=GenerateKeyResponse)
async def generate_key(
    request: GenerateKeyRequest,
    admin_key: str = Depends(validate_admin_key),
):
    """Generate a new API key.

    Requires the X-Admin-Key header to match the ADMIN_API_KEY environment
    variable (when set).  In development, if ADMIN_API_KEY is not configured,
    the endpoint is open so that the initial key can be created easily.
    """
    api_key = f"mea_{secrets.token_urlsafe(32)}"
    created_at = datetime.now().isoformat()
    api_keys = load_api_keys()
    api_keys[api_key] = {
        "name": request.name,
        "description": request.description,
        "created_at": created_at,
        "last_used": None,
        "request_count": 0,
        "active": True,
    }
    save_api_keys(api_keys)
    logger.info("New API key generated for: %s", request.name)
    return GenerateKeyResponse(
        api_key=api_key,
        name=request.name,
        created_at=created_at,
    )