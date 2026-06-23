"""WageWise FastAPI Backend – entry point."""

import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import get_settings

logging.basicConfig(
    level=logging.WARNING,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
# Suppress noisy chromadb telemetry errors (posthog SDK version mismatch — harmless)
logging.getLogger("chromadb.telemetry.product.posthog").setLevel(logging.CRITICAL)
from services.salary_service import router as salary_router
from services.chatbot_service import router as chat_router
from services.col_service import router as col_router

settings = get_settings()

app = FastAPI(
    title="WageWise API",
    version="1.0.0",
    description="Backend AI services for WageWise – Fair Wage Navigator",
)

_prod_origins = [
    "http://localhost:5000",
    "http://localhost:8080",
    "http://localhost:3000",
    "http://localhost:4200",
    "http://127.0.0.1:5000",
    "http://127.0.0.1:8000",
    "http://127.0.0.1:8080",
    "http://127.0.0.1:3000",
]

if settings.app_env == "development":
    # Flutter web dev server binds to a random port — allow all origins in dev.
    # allow_credentials must be False when allow_origins=["*"] (CORS spec).
    # Flutter uses JWT in headers, not cookies, so credentials are not needed.
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
else:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=list(set(settings.cors_origins + _prod_origins)),
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(salary_router, prefix="/predict", tags=["Salary Intelligence"])
app.include_router(chat_router, prefix="/chat", tags=["AI Chatbot"])
app.include_router(col_router, prefix="/col", tags=["Cost of Living"])


@app.get("/health", tags=["Health"])
async def health():
    return {"status": "ok", "version": "1.0.0"}
