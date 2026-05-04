# WageWise – Fair Wage Navigator

> A comprehensive Android mobile application empowering Malaysian fresh graduates with data-driven salary insights, AI-powered labour rights consultation, and cost-of-living wage evaluation.

**Student:** Chew Xu Sheng (ID: 2407975)  
**Supervisor:** Ms Lehka A/P Subramanium  
**Institution:** TAR UMT – Faculty of Computing and Information Technology  
**Programme:** Bachelor of Software Engineering (Honours)  
**Academic Year:** 2025/2026

---

## Architecture Overview

```
┌────────────────────────────────────────────────────────────┐
│         TIER 1 – PRESENTATION (Flutter Android App)        │
│  Salary Intelligence │ Labour Rights │ COL Evaluator        │
└───────────────────────────┬────────────────────────────────┘
                            │ HTTPS / REST API
┌───────────────────────────▼────────────────────────────────┐
│        TIER 2 – APPLICATION (Python FastAPI Backend)        │
│  Salary Service (XGBoost/RF) │ RAG Chatbot │ COL Service   │
└──────┬──────────────────────┬──────────────────────────────┘
       │ Supabase SDK / SQL   │ ChromaDB / LLM API
┌──────▼──────────────────────▼──────────────────────────────┐
│         TIER 3 – DATA (Storage & Knowledge Bases)           │
│  Supabase PostgreSQL │ ChromaDB Vector Store │ HuggingFace  │
└────────────────────────────────────────────────────────────┘
```

## Modules

| Module | Description |
|--------|-------------|
| **Salary Intelligence** | XGBoost/Random Forest predictions on the HuggingFace `azrai99/job-dataset`; returns p25/p50/p75 salary ranges |
| **AI Labour Rights Chatbot** | RAG pipeline (ChromaDB + LLM) grounded in Employment Act 1955 & Industrial Relations Act 1967 |
| **Cost-of-Living Evaluator** | EPF/SOCSO/tax deductions + district-level expense data across Malaysian cities |
| **Negotiation Coach** | Scenario-based AI roleplay (Google Gemini API) for salary negotiation practice |

---

## Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Flutter SDK | 3.22.x |
| Dart | 3.4.x |
| Python | 3.11+ |
| Android Studio / SDK | API 24+ (Android 7) |
| Supabase account | – |
| Google Gemini API key | – |

---

## Quick Start

### 1 – Clone the repository

```bash
git clone https://github.com/<your-username>/wagewise.git
cd wagewise
```

### 2 – Configure environment variables

```bash
cp .env.example .env
# Edit .env with your actual keys (see table below)
```

### 3 – Set up Supabase

1. Create a new project at [supabase.com](https://supabase.com).
2. Open **SQL Editor** and run `supabase/schema.sql` to create all tables, indexes, and RLS policies.
3. Enable **Email Auth** under Authentication → Providers.
4. Copy your **Project URL** and **anon public key** into `.env`.

### 4 – Start the Python backend

```bash
cd backend
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at `http://localhost:8000`.  
Swagger docs: `http://localhost:8000/docs`

### 5 – Run the Flutter app

```bash
cd mobile_app
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `SUPABASE_URL` | Supabase project URL | `https://xxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anon/public key | `eyJhbGci...` |
| `SUPABASE_SERVICE_KEY` | Supabase service role key (backend only) | `eyJhbGci...` |
| `GEMINI_API_KEY` | Google Gemini API key | `AIzaSy...` |
| `BACKEND_URL` | Python FastAPI base URL | `http://10.0.2.2:8000` |
| `CHROMA_PERSIST_DIR` | ChromaDB persistence path | `./chroma_db` |
| `MODEL_PATH` | Path to trained ML model | `./models/salary_model.pkl` |
| `SECRET_KEY` | FastAPI JWT secret | `your-secret-key` |

> **Note:** `10.0.2.2` is the Android emulator's alias for `localhost`. Use your machine's LAN IP for physical device testing.

---

## Project Structure

```
wagewise/
├── README.md
├── .env.example
├── .gitignore
├── supabase/
│   └── schema.sql            # Run this in Supabase SQL Editor
├── backend/
│   ├── requirements.txt
│   ├── main.py               # FastAPI entry point
│   ├── config.py             # Settings loaded from .env
│   └── services/
│       ├── salary_service.py # ML salary prediction
│       ├── chatbot_service.py# RAG pipeline
│       └── col_service.py    # Cost-of-living calculator
└── mobile_app/
    ├── pubspec.yaml
    ├── android/              # ADB / Gradle build files
    └── lib/
        ├── main.dart
        ├── l10n/             # ARB translation files (EN/BM/ZH/TA)
        ├── config/           # Colors & theme
        ├── models/           # Data classes
        ├── services/         # API & Supabase clients
        ├── providers/        # State management
        ├── screens/          # UI screens
        └── widgets/          # Reusable widgets
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `POST` | `/predict` | Salary prediction |
| `POST` | `/chat` | RAG chatbot query |
| `POST` | `/col` | Cost-of-living breakdown |
| `POST` | `/contract/analyse` | Contract clause analysis |

---

## Running Tests

```bash
# Flutter unit & widget tests
cd mobile_app
flutter test

# Backend API tests
cd backend
pytest tests/ -v
```

---

## Multilingual Support

WageWise supports four languages via Flutter ARB localisation:

| Code | Language |
|------|----------|
| `en` | English |
| `bm` | Bahasa Malaysia |
| `zh` | 中文 (Simplified Chinese) |
| `ta` | தமிழ் (Tamil) |

ARB files are located in `mobile_app/lib/l10n/`.

---

## License

Copyright © 2026 Tunku Abdul Rahman University of Management and Technology. All rights reserved.
