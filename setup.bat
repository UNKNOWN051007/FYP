@echo off
echo ============================================
echo  WageWise - Pre-Installation Setup
echo ============================================
echo.

REM === STEP 1: Backend Python setup ===
echo [1/5] Setting up Python virtual environment...
cd /d "%~dp0backend"
if not exist ".venv" (
    python -m venv .venv
    if errorlevel 1 (echo ERROR: Python not found. Install Python 3.11+ first. && pause && exit /b 1)
)
call .venv\Scripts\activate.bat
echo [2/5] Installing Python dependencies...
pip install -r requirements.txt --quiet
if errorlevel 1 (echo ERROR: pip install failed. && pause && exit /b 1)

REM === STEP 2: Train ML model ===
echo [3/5] Training salary prediction model (first run only)...
if not exist "models\salary_model.pkl" (
    python train_model.py
) else (
    echo      Model already trained, skipping.
)

REM === STEP 3: Initialize ChromaDB ===
echo [4/5] Initializing ChromaDB vector store (first run only)...
if not exist "chroma_db" (
    python init_chroma.py
) else (
    echo      ChromaDB already initialized, skipping.
)
cd /d "%~dp0"

REM === STEP 4: Flutter setup ===
echo [5/5] Setting up Flutter web app...
cd /d "%~dp0mobile_app"
if not exist "assets" mkdir assets

REM Copy .env for Flutter
if not exist "assets\.env" (
    if exist "%~dp0.env" (
        copy "%~dp0.env" "assets\.env" >nul
        echo      Copied root .env to mobile_app\assets\.env
    ) else (
        echo      WARNING: No .env file found at project root.
        echo      Create a .env file with SUPABASE_URL, SUPABASE_ANON_KEY, BACKEND_URL
    )
)

REM Check Flutter installation
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found. Install Flutter SDK and add to PATH.
    echo Download: https://flutter.dev/docs/get-started/install
    pause && exit /b 1
)

flutter pub get
if errorlevel 1 (echo ERROR: flutter pub get failed. && pause && exit /b 1)

echo.
echo ============================================
echo  Setup complete!
echo  Run 'run.bat' to start the application.
echo ============================================
cd /d "%~dp0"
pause
