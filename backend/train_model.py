"""
Train salary prediction model and save to models/salary_model.pkl.
Run once before starting the backend: python train_model.py

Tries to load the HuggingFace dataset (azrai99/job-dataset).
Falls back to synthetic Malaysian salary data if the dataset is unavailable.
"""

import os
import sys
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.multioutput import MultiOutputRegressor
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")
MODEL_PATH = os.path.join(MODELS_DIR, "salary_model.pkl")
ENCODER_PATH = os.path.join(MODELS_DIR, "label_encoders.pkl")

CATEGORICAL_COLS = ["job_title", "industry", "education_level", "location"]

# ── Synthetic fallback data ───────────────────────────────────────────────────

_INDUSTRIES = [
    "Information Technology", "Engineering", "Business/Finance",
    "Healthcare", "Education", "Marketing", "Manufacturing", "Legal",
]
_EDUCATIONS = ["Diploma", "Bachelor's Degree", "Master's Degree", "PhD"]
_LOCATIONS = [
    "Kuala Lumpur", "Penang", "Johor Bahru", "Shah Alam",
    "Kota Kinabalu", "Kuching", "Ipoh", "Kota Bharu",
]
_TITLES = [
    "Software Engineer", "Data Analyst", "Marketing Executive",
    "Accountant", "Mechanical Engineer", "HR Executive",
    "Business Analyst", "Nurse", "Teacher", "Lawyer",
    "Civil Engineer", "IT Support", "Graphic Designer",
    "Finance Analyst", "Operations Executive",
]

BASE_SALARY = {
    "Information Technology": 4200, "Engineering": 3800,
    "Business/Finance": 3600, "Healthcare": 3700,
    "Education": 3000, "Marketing": 3400,
    "Manufacturing": 3300, "Legal": 4000,
}
LOC_MULT = {
    "Kuala Lumpur": 1.10, "Penang": 0.98, "Johor Bahru": 0.94,
    "Shah Alam": 1.04, "Kota Kinabalu": 0.83, "Kuching": 0.81,
    "Ipoh": 0.79, "Kota Bharu": 0.76,
}
EDU_MULT = {
    "Diploma": 0.82, "Bachelor's Degree": 1.00,
    "Master's Degree": 1.28, "PhD": 1.58,
}


def _synthetic_salary(industry, edu, location, exp):
    base = BASE_SALARY.get(industry, 3500)
    m = (base + exp * 160) * LOC_MULT.get(location, 1.0) * EDU_MULT.get(edu, 1.0)
    noise = np.random.normal(0, m * 0.08)
    median = max(1700, m + noise)
    return median * 0.78, median, median * 1.38


def _build_synthetic_dataset(n: int = 3000) -> pd.DataFrame:
    rng = np.random.default_rng(42)
    rows = []
    for _ in range(n):
        ind = rng.choice(_INDUSTRIES)
        edu = rng.choice(_EDUCATIONS)
        loc = rng.choice(_LOCATIONS)
        title = rng.choice(_TITLES)
        exp = int(rng.integers(0, 16))
        p25, p50, p75 = _synthetic_salary(ind, edu, loc, exp)
        rows.append({
            "job_title": title, "industry": ind,
            "education_level": edu, "years_experience": exp,
            "location": loc,
            "salary_p25": round(p25, 2),
            "salary_p50": round(p50, 2),
            "salary_p75": round(p75, 2),
        })
    return pd.DataFrame(rows)


def _load_hf_dataset() -> pd.DataFrame | None:
    try:
        from datasets import load_dataset
        print("Downloading HuggingFace dataset azrai99/job-dataset …")
        ds = load_dataset("azrai99/job-dataset", split="train")
        df = ds.to_pandas()
        print(f"  Downloaded {len(df)} rows. Columns: {list(df.columns)}")

        # Map whatever columns exist to the expected schema
        col_map = {}
        for c in df.columns:
            cl = c.lower().replace(" ", "_")
            if "title" in cl or "job" in cl and "title" in cl:
                col_map[c] = "job_title"
            elif "industry" in cl or "sector" in cl:
                col_map[c] = "industry"
            elif "edu" in cl or "qualification" in cl:
                col_map[c] = "education_level"
            elif "exp" in cl or "year" in cl:
                col_map[c] = "years_experience"
            elif "locat" in cl or "city" in cl or "state" in cl:
                col_map[c] = "location"
            elif "salary" in cl or "wage" in cl or "pay" in cl:
                col_map[c] = "salary"

        df = df.rename(columns=col_map)

        required = {"job_title", "industry", "education_level",
                    "years_experience", "location", "salary"}
        if not required.issubset(df.columns):
            missing = required - set(df.columns)
            print(f"  Dataset missing columns {missing}; falling back to synthetic data.")
            return None

        df["years_experience"] = pd.to_numeric(df["years_experience"], errors="coerce").fillna(0).astype(int)
        df["salary"] = pd.to_numeric(df["salary"], errors="coerce")
        df = df.dropna(subset=["salary"])

        # Derive percentiles per (job_title, industry, education_level, location) group
        grp = df.groupby(["job_title", "industry", "education_level", "location"])
        pct = grp["salary"].quantile([0.25, 0.50, 0.75]).unstack(level=-1)
        pct.columns = ["salary_p25", "salary_p50", "salary_p75"]

        df = df.merge(pct, on=["job_title", "industry", "education_level", "location"], how="left")
        df["salary_p25"] = df["salary_p25"].fillna(df["salary"] * 0.78)
        df["salary_p50"] = df["salary_p50"].fillna(df["salary"])
        df["salary_p75"] = df["salary_p75"].fillna(df["salary"] * 1.38)

        df = df[["job_title", "industry", "education_level",
                  "years_experience", "location",
                  "salary_p25", "salary_p50", "salary_p75"]]
        return df.drop_duplicates()

    except Exception as exc:
        print(f"  Could not load HuggingFace dataset: {exc}")
        return None


def train():
    os.makedirs(MODELS_DIR, exist_ok=True)

    df = _load_hf_dataset()
    if df is None or len(df) < 100:
        print("Using synthetic salary dataset …")
        df = _build_synthetic_dataset(3000)
    else:
        print(f"Using HuggingFace dataset ({len(df)} rows).")

    # ── Encode categoricals ───────────────────────────────────────
    encoders: dict[str, LabelEncoder] = {}
    for col in CATEGORICAL_COLS:
        le = LabelEncoder()
        df[col] = le.fit_transform(df[col].astype(str))
        encoders[col] = le

    X = df[["job_title", "industry", "education_level", "years_experience", "location"]].values
    y = df[["salary_p25", "salary_p50", "salary_p75"]].values

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42)

    print("Training MultiOutputRegressor(GradientBoostingRegressor) …")
    model = MultiOutputRegressor(
        GradientBoostingRegressor(n_estimators=200, max_depth=5, learning_rate=0.08, random_state=42),
        n_jobs=-1,
    )
    model.fit(X_train, y_train)

    score = model.score(X_test, y_test)
    print(f"  R² on test set: {score:.4f}")

    joblib.dump(model, MODEL_PATH)
    joblib.dump(encoders, ENCODER_PATH)
    print(f"  Saved model  → {MODEL_PATH}")
    print(f"  Saved encoders → {ENCODER_PATH}")
    print("Done. You can now start the backend server.")


if __name__ == "__main__":
    train()
