"""
Train the salary prediction model and save to models/salary_model.pkl.

IMPORTANT: run this with the SAME Python environment the backend uses,
otherwise the pickle is written by a different scikit-learn version and the
backend will silently fall back to heuristic predictions
(InconsistentVersionWarning at startup):

    .venv\\Scripts\\python.exe train_model.py

Data sources (in priority order):
  1. HuggingFace dataset azrai99/job-dataset (if reachable)
  2. Synthetic dataset generated from data/job_titles.py per-title baselines,
     which are anchored to public Malaysian salary surveys (Hays, PIKOM,
     Robert Walters, JobStreet, Michael Page) — see data/job_titles.py.

The previous training script only knew about 15 generic job titles and used
the industry as the salary signal, so the model couldn't distinguish e.g.
'Data Scientist' (~RM 5,800) from 'IT Support Specialist' (~RM 3,000) in
the same industry. This version uses ~270 per-title baselines.

To add MORE data later (recommended for production):
  - Scrape JobStreet / Hiredly / Indeed Malaysia listings (respect ToS),
    parse the salary range, write rows to a CSV with the same columns
    used here, and load it via the `_load_csv_dataset` helper.
"""

import os
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.multioutput import MultiOutputRegressor
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

from data.job_titles import JOB_TITLE_BASELINES

MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
MODEL_PATH = os.path.join(MODELS_DIR, "salary_model.pkl")
ENCODER_PATH = os.path.join(MODELS_DIR, "label_encoders.pkl")
EXTRA_CSV = os.path.join(DATA_DIR, "extra_salaries.csv")

CATEGORICAL_COLS = ["job_title", "industry", "education_level", "location"]

# Location / education multipliers — anchored to KL Bachelor's = 1.00
LOC_MULT = {
    "Kuala Lumpur": 1.10, "Shah Alam": 1.05, "Penang": 0.97,
    "Johor Bahru": 0.93, "Ipoh": 0.82, "Kota Kinabalu": 0.85,
    "Kuching": 0.83, "Kota Bharu": 0.78,
}
EDU_MULT = {
    "SPM/O-Level": 0.65,
    "Diploma": 0.82,
    "Bachelor's Degree": 1.00,
    "Master's Degree": 1.25,
    "PhD": 1.55,
}
EDUCATIONS = list(EDU_MULT.keys())
LOCATIONS = list(LOC_MULT.keys())


def _synthetic_row(rng: np.random.Generator, title: str, industry: str, base: int):
    """Generate one realistic synthetic data point for the given title."""
    edu = rng.choice(EDUCATIONS)
    loc = rng.choice(LOCATIONS)
    # Experience distribution skewed toward 0-5 yrs (fresh-grad target user)
    exp = int(min(40, max(0, rng.gamma(2.0, 2.5))))

    # Experience adds RM 180-280 per year depending on the title tier
    per_year = 180 + (base / 50)  # higher-paying roles grow faster
    median = (base + exp * per_year) * LOC_MULT[loc] * EDU_MULT[edu]
    median = max(1700, median)  # Malaysian minimum wage floor
    noise = rng.normal(0, median * 0.08)
    median = max(1700, median + noise)

    return {
        "job_title": title,
        "industry": industry,
        "education_level": edu,
        "years_experience": exp,
        "location": loc,
        "salary_p25": round(median * 0.78, 2),
        "salary_p50": round(median, 2),
        "salary_p75": round(median * 1.38, 2),
    }


def _build_synthetic_dataset(samples_per_title: int = 60) -> pd.DataFrame:
    """Generate a synthetic dataset with samples_per_title rows per role."""
    rng = np.random.default_rng(42)
    rows = []
    for industry, entries in JOB_TITLE_BASELINES.items():
        for title, base in entries:
            for _ in range(samples_per_title):
                rows.append(_synthetic_row(rng, title, industry, base))
    return pd.DataFrame(rows)


def _load_csv_dataset() -> pd.DataFrame | None:
    """Optional extension point: load real scraped data from data/extra_salaries.csv.

    Expected columns: job_title, industry, education_level, years_experience,
    location, salary_p25, salary_p50, salary_p75
    """
    if not os.path.exists(EXTRA_CSV):
        return None
    try:
        df = pd.read_csv(EXTRA_CSV)
        required = {
            "job_title", "industry", "education_level",
            "years_experience", "location",
            "salary_p25", "salary_p50", "salary_p75",
        }
        if not required.issubset(df.columns):
            print(f"  {EXTRA_CSV} missing required columns; ignoring.")
            return None
        print(f"  Loaded {len(df)} extra rows from {EXTRA_CSV}.")
        return df
    except Exception as exc:
        print(f"  Could not read {EXTRA_CSV}: {exc}")
        return None


def _load_hf_dataset() -> pd.DataFrame | None:
    try:
        from datasets import load_dataset
        print("Trying HuggingFace dataset azrai99/job-dataset ...")
        ds = load_dataset("azrai99/job-dataset", split="train")
        df = ds.to_pandas()
        print(f"  Downloaded {len(df)} rows. Columns: {list(df.columns)}")

        col_map = {}
        for c in df.columns:
            cl = c.lower().replace(" ", "_")
            if "title" in cl or ("job" in cl and "title" in cl):
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
            print(f"  HF dataset missing {required - set(df.columns)}; skipping.")
            return None

        df["years_experience"] = pd.to_numeric(df["years_experience"], errors="coerce").fillna(0).astype(int)
        df["salary"] = pd.to_numeric(df["salary"], errors="coerce")
        df = df.dropna(subset=["salary"])

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
        print(f"  HF dataset unavailable: {exc}")
        return None


def train():
    os.makedirs(MODELS_DIR, exist_ok=True)

    print("Building synthetic dataset from per-title baselines ...")
    df = _build_synthetic_dataset(samples_per_title=60)
    print(f"  Synthetic rows: {len(df)} across {df['job_title'].nunique()} titles.")

    hf = _load_hf_dataset()
    if hf is not None and len(hf) >= 100:
        df = pd.concat([df, hf], ignore_index=True)
        print(f"  + HuggingFace: {len(hf)} rows. Total: {len(df)}")

    extra = _load_csv_dataset()
    if extra is not None:
        df = pd.concat([df, extra], ignore_index=True)
        print(f"  + CSV extras: {len(extra)} rows. Total: {len(df)}")

    df = df.dropna(subset=["salary_p50"]).drop_duplicates()

    # ── Encode categoricals ───────────────────────────────────────
    encoders: dict[str, LabelEncoder] = {}
    for col in CATEGORICAL_COLS:
        le = LabelEncoder()
        df[col] = le.fit_transform(df[col].astype(str))
        encoders[col] = le

    X = df[["job_title", "industry", "education_level", "years_experience", "location"]].values
    y = df[["salary_p25", "salary_p50", "salary_p75"]].values

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42)

    print(f"\nTraining MultiOutputRegressor(GradientBoostingRegressor) on {len(X_train)} rows ...")
    model = MultiOutputRegressor(
        GradientBoostingRegressor(n_estimators=250, max_depth=5, learning_rate=0.08, random_state=42),
        n_jobs=-1,
    )
    model.fit(X_train, y_train)

    score = model.score(X_test, y_test)
    print(f"  R² on test set: {score:.4f}")

    joblib.dump(model, MODEL_PATH)
    joblib.dump(encoders, ENCODER_PATH)
    print(f"\n  Saved model    -> {MODEL_PATH}")
    print(f"  Saved encoders -> {ENCODER_PATH}")
    print("\nDone. Restart the backend so it picks up the new model.")


if __name__ == "__main__":
    train()
