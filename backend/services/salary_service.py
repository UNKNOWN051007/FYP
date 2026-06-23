"""
Salary Intelligence Service
Loads a trained XGBoost/Random Forest model and returns p25/p50/p75
salary predictions for Malaysian job market.

Training script: run `python train_model.py` once to build models/salary_model.pkl
"""

import os
import joblib
import numpy as np
import pandas as pd
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field, field_validator

from config import get_settings
from data.job_titles import (
    CANONICAL_INDUSTRIES,
    JOB_TITLE_BASELINES,
    is_canonical_title,
    looks_like_job_title,
)

router = APIRouter()
settings = get_settings()

_model = None
_encoders = None


def _load_model():
    global _model, _encoders
    if _model is None:
        if not os.path.exists(settings.model_path):
            raise FileNotFoundError(
                f"Model not found at {settings.model_path}. "
                "Run `python train_model.py` first."
            )
        _model = joblib.load(settings.model_path)
        _encoders = joblib.load(settings.encoder_path)
    return _model, _encoders


# ── Request / Response schemas ────────────────────────────────

class PredictRequest(BaseModel):
    job_title: str = Field(..., example="Software Engineer", min_length=4, max_length=60)
    industry: str = Field(..., example="Information Technology")
    education_level: str = Field(..., example="Bachelor's Degree")
    years_experience: int = Field(..., ge=0, le=40, example=0)
    location: str = Field(..., example="Kuala Lumpur")

    @field_validator("industry")
    @classmethod
    def _check_industry(cls, v: str) -> str:
        if v not in CANONICAL_INDUSTRIES:
            raise ValueError(
                f"industry must be one of {sorted(CANONICAL_INDUSTRIES)}"
            )
        return v

    @field_validator("job_title")
    @classmethod
    def _check_job_title(cls, v: str) -> str:
        v = v.strip()
        # Accept canonical titles outright (case-insensitive)
        if is_canonical_title(v):
            return v
        # For free-text fallback (industry == "Others"), require it to look
        # like a real job title — rejects "bla", "asdf", "12345", "!@#" etc.
        if not looks_like_job_title(v):
            raise ValueError(
                "job_title doesn't look like a real role. "
                "Pick from the suggested list or enter a proper title "
                "(e.g. 'Software Engineer', 'Mechanical Engineer')."
            )
        return v


class SalaryRange(BaseModel):
    p25: float
    p50: float
    p75: float
    confidence: str


class PredictResponse(BaseModel):
    job_title: str
    location: str
    salary_range: SalaryRange
    dataset_records: int
    offer_evaluation: dict | None = None


# ── Fallback heuristics (used before model is trained) ───────

_BASE_SALARY: dict[str, float] = {
    "Information Technology": 3800,
    "Engineering": 3600,
    "Business/Finance": 3400,
    "Healthcare": 3500,
    "Education": 2800,
    "Marketing": 3200,
    "Default": 3000,
}

_LOCATION_MULTIPLIER: dict[str, float] = {
    "Kuala Lumpur": 1.08,
    "Penang": 0.97,
    "Johor Bahru": 0.92,
    "Kota Kinabalu": 0.82,
    "Kuching": 0.80,
    "Shah Alam": 1.02,
}

_EDU_MULTIPLIER: dict[str, float] = {
    "Diploma": 0.85,
    "Bachelor's Degree": 1.00,
    "Master's Degree": 1.25,
    "PhD": 1.50,
}


# Per-title base lookup so the heuristic actually uses the job title
# instead of just the industry average.
_TITLE_BASE: dict[str, int] = {
    title: base
    for entries in JOB_TITLE_BASELINES.values()
    for title, base in entries
}


def _heuristic_predict(req: PredictRequest) -> SalaryRange:
    title_base = _TITLE_BASE.get(req.job_title)
    base = title_base if title_base is not None else _BASE_SALARY.get(
        req.industry, _BASE_SALARY["Default"]
    )
    loc_m = _LOCATION_MULTIPLIER.get(req.location, 1.0)
    edu_m = _EDU_MULTIPLIER.get(req.education_level, 1.0)
    exp_bonus = req.years_experience * 200

    median = (base + exp_bonus) * loc_m * edu_m
    # Heuristic confidence stays below the ML model's "high": "medium" when the
    # title is in our curated catalogue, "low" when we're guessing by industry.
    confidence = "medium" if title_base is not None else "low"
    return SalaryRange(
        p25=round(median * 0.78, 2),
        p50=round(median, 2),
        p75=round(median * 1.38, 2),
        confidence=confidence,
    )


# ── Routes ────────────────────────────────────────────────────

@router.post("", response_model=PredictResponse)
async def predict_salary(req: PredictRequest):
    try:
        model, encoders = _load_model()
        features = _encode_features(req, encoders)
        preds = model.predict(features)
        salary_range = SalaryRange(
            p25=round(float(preds[0][0]), 2),
            p50=round(float(preds[0][1]), 2),
            p75=round(float(preds[0][2]), 2),
            confidence="high",
        )
        records = 1240
    except Exception:
        salary_range = _heuristic_predict(req)
        records = 0

    return PredictResponse(
        job_title=req.job_title,
        location=req.location,
        salary_range=salary_range,
        dataset_records=records,
    )


@router.post("/evaluate-offer")
async def evaluate_offer(req: PredictRequest, offer: float = Query(..., gt=0, description="Offered salary in RM")):
    pred = await predict_salary(req)
    p50 = pred.salary_range.p50
    diff = offer - p50
    if offer < pred.salary_range.p25:
        status = "below_market"
    elif offer > pred.salary_range.p75:
        status = "above_market"
    else:
        status = "at_market"

    return {
        "offer": offer,
        "median": p50,
        "difference": round(diff, 2),
        "status": status,
        "negotiation_tip": _negotiation_tip(status, diff, p50),
    }


def _negotiation_tip(status: str, diff: float, median: float) -> str:
    if status == "below_market":
        return (
            f"Your offer is RM {abs(diff):.0f} below median. "
            f"You have room to negotiate up to RM {median:.0f}. "
            "Reference market data from WageWise when countering."
        )
    if status == "above_market":
        return "Your offer is above market rate. Consider accepting or negotiating other benefits."
    return "Your offer aligns with market rate. You may still negotiate benefits or scope."


def _encode_features(req: PredictRequest, encoders: dict) -> np.ndarray:
    row = {
        "job_title": req.job_title,
        "industry": req.industry,
        "education_level": req.education_level,
        "years_experience": req.years_experience,
        "location": req.location,
    }
    df = pd.DataFrame([row])
    for col, le in encoders.items():
        if col in df.columns:
            df[col] = le.transform(df[col].astype(str))
    return df.values
