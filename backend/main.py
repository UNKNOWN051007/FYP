"""WageWise FastAPI Backend – entry point."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import get_settings
from services.salary_service import router as salary_router
from services.chatbot_service import router as chat_router
from services.col_service import router as col_router

settings = get_settings()

app = FastAPI(
    title="WageWise API",
    version="1.0.0",
    description="Backend AI services for WageWise – Fair Wage Navigator",
)

_dev_origins = [
    "http://localhost:5000",
    "http://localhost:8080",
    "http://localhost:3000",
    "http://localhost:4200",
    "http://127.0.0.1:5000",
    "http://127.0.0.1:8000",
    "http://127.0.0.1:8080",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=list(set(settings.cors_origins + _dev_origins)),
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
