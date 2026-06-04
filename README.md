# WageWise

**Fair Wage Navigator for Malaysian Fresh Graduates**

WageWise helps fresh graduates in Malaysia make informed career decisions with AI-powered salary predictions, labour rights consultation, cost-of-living analysis, and salary negotiation coaching.

---

## Features

| Feature | Description |
|---|---|
| **Salary Intelligence** | XGBoost/GradientBoosting ML predictions with P25/P50/P75 range |
| **Offer Evaluation** | Compare your offer against market rates |
| **Labour Rights Bot** | RAG chatbot powered by ChromaDB + Gemini, covering EA 1955, EPF, SOCSO |
| **Negotiation Coach** | AI roleplay coach for salary negotiation practice |
| **Contract Analysis** | AI review of employment contract clauses |
| **Cost of Living** | EPF/SOCSO/tax deductions + expense breakdown across 8 Malaysian cities |
| **Multilingual** | English, Bahasa Malaysia, 中文, தமிழ் |

---

## Tech Stack

- **Frontend**: Flutter (web, runs on Chrome)
- **Backend**: Python FastAPI
- **Database**: Supabase (PostgreSQL + Auth)
- **Vector Store**: ChromaDB (RAG)
- **ML**: XGBoost, scikit-learn
- **LLM**: Google Gemini 1.5 Flash

---

## Prerequisites

Install these before running setup:

1. **Python 3.11+** — https://python.org/downloads
2. **Flutter SDK** — https://flutter.dev/docs/get-started/install  
   (Enable web: `flutter config --enable-web`)
3. **Google Chrome** browser
4. **Git** (optional)

---

## Environment Setup

Create a `.env` file at the project root:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# Google Gemini
GEMINI_API_KEY=your-gemini-api-key

# Optional overrides
BACKEND_URL=http://localhost:8000
```

> Get Supabase credentials at https://supabase.com  
> Get Gemini API key at https://aistudio.google.com

Then run the Supabase schema:
```sql
-- Paste contents of supabase/schema.sql into Supabase SQL Editor
```

---

## Quick Start

### First-time setup (run once)

```bat
.\setup.bat
```

This will:
1. Create Python virtual environment
2. Install all Python dependencies
3. Train the salary prediction ML model
4. Initialize ChromaDB with Malaysian legal documents
5. Install Flutter dependencies

### Run the app (every time)

```bat
.\run.bat
```

This starts:
- **Backend** at `http://localhost:8000` (FastAPI + auto-reload)
- **Frontend** Flutter web app on Chrome

---

## Manual Start (alternative)

**Backend:**
```bash
cd backend
.venv\Scripts\activate      # Windows
# source .venv/bin/activate  # Mac/Linux
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

**Frontend:**
```bash
cd mobile_app
flutter run -d chrome
```

---

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/predict` | Salary prediction |
| POST | `/predict/evaluate-offer` | Offer evaluation |
| POST | `/chat` | AI chatbot (labour rights / negotiation) |
| POST | `/chat/contract` | Contract clause analysis |
| POST | `/col` | Cost of living evaluation |
| GET | `/col/cities` | Available cities |

Interactive API docs: `http://localhost:8000/docs`

---

## Project Structure

```
WageWise/
├── backend/                    # FastAPI Python backend
│   ├── main.py                 # App entry point + routers
│   ├── config.py               # Settings (Pydantic)
│   ├── requirements.txt        # Python dependencies
│   ├── train_model.py          # ML model training
│   ├── init_chroma.py          # ChromaDB initialization
│   ├── models/                 # Trained model files
│   └── services/
│       ├── salary_service.py   # ML predictions
│       ├── chatbot_service.py  # RAG + Gemini
│       └── col_service.py      # Cost-of-living
├── mobile_app/                 # Flutter web app
│   ├── lib/
│   │   ├── main.dart           # Entry point
│   │   ├── config/             # Theme, colors, env
│   │   ├── models/             # Data models
│   │   ├── services/           # API, auth, supabase
│   │   ├── providers/          # App state (ChangeNotifier)
│   │   ├── l10n/               # ARB localization files
│   │   ├── screens/            # App screens
│   │   └── widgets/            # Shared widgets
│   ├── assets/.env             # Copied from root .env
│   └── pubspec.yaml
├── supabase/
│   └── schema.sql              # Database schema + RLS
├── setup.bat                   # One-time pre-installation
├── run.bat                     # Daily run command
└── .env                        # Environment variables (create this)
```

---

## Supported Languages

| Code | Language | Status |
|------|----------|--------|
| `en` | English | Full |
| `ms` | Bahasa Malaysia | Full |
| `zh` | 中文 (Simplified) | Full |
| `ta` | தமிழ் | Full |

Change language in the **Profile** tab.

---

## Database Schema

Run `supabase/schema.sql` in Supabase SQL Editor. Creates:
- `user_profiles` — user info + language preference
- `salary_predictions` — prediction history
- `chat_sessions` / `chat_messages` — conversation history
- `col_evaluations` — cost-of-living history

Row Level Security (RLS) is enabled — users can only access their own data.

---

## Troubleshooting

**Flutter not found:**
```bash
flutter doctor
flutter config --enable-web
```

**Backend fails to start:**
- Check `.env` has valid `GEMINI_API_KEY` and `SUPABASE_URL`
- Re-run: `cd backend && python train_model.py && python init_chroma.py`

**CORS error in browser:**
- Make sure backend is running on `http://localhost:8000`
- Check the browser console for the exact origin and add it to CORS if needed

**Flutter web blank screen:**
- Open Chrome DevTools → Console for errors
- Verify `assets/.env` exists and has correct Supabase credentials

---

## Academic Context

This project was developed as a Final Year Project (FYP) at **TAR UMT** (2026).

> **Disclaimer**: Salary predictions are estimates based on synthetic/public datasets and should not be used as the sole basis for salary decisions.
