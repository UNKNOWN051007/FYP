@echo off
setlocal enabledelayedexpansion

:: ================================================================
::  WageWise - One-Click Startup Script (Windows)
::  Starts FastAPI backend + React Native (Expo) mobile app.
::  Run from project root: .\start.bat
:: ================================================================

title WageWise Startup
cd /d "%~dp0"

echo.
echo  ============================================
echo    WageWise - Fair Wage Navigator
echo    Startup Script v2.0
echo  ============================================
echo.

:: -- Check Python --
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Install Python 3.11+ from https://python.org
    pause
    exit /b 1
)

:: -- Check Node.js --
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js not found. Install Node.js 18+ from https://nodejs.org
    pause
    exit /b 1
)

:: -- Set up backend virtual environment --
echo [1/6] Setting up Python virtual environment...
if not exist "backend\.venv" (
    python -m venv backend\.venv
    if errorlevel 1 (
        echo [ERROR] Failed to create venv.
        pause
        exit /b 1
    )
    echo       Virtual environment created.
) else (
    echo       Virtual environment already exists.
)

call backend\.venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Failed to activate venv.
    pause
    exit /b 1
)

:: -- Install Python dependencies --
echo.
echo [2/6] Installing Python dependencies...
pip install -r backend\requirements.txt --quiet --disable-pip-version-check
if errorlevel 1 (
    echo [ERROR] pip install failed.
    pause
    exit /b 1
)
echo       Dependencies OK.

:: -- Train salary model if missing --
echo.
echo [3/6] Checking ML model files...
if not exist "backend\models\salary_model.pkl" (
    echo       Training salary model - first run only...
    python backend\train_model.py
    if errorlevel 1 (
        echo [WARNING] Model training failed. Backend will use fallback.
    )
) else (
    echo       Salary model found.
)

:: -- Initialise ChromaDB --
echo.
echo [4/6] Checking ChromaDB vector store...
if not exist "backend\chroma_db" (
    echo       Initialising legal knowledge base...
    python backend\init_chroma.py
    if errorlevel 1 (
        echo [WARNING] ChromaDB init failed. Chatbot will work without local context.
    )
) else (
    echo       ChromaDB found.
)

:: -- Check .env --
echo.
echo [5/6] Checking environment configuration...
if not exist ".env" (
    echo [WARNING] .env not found. Using defaults.
    echo           Edit .env with your Supabase and Gemini API keys!
) else (
    echo       .env file found.
)

:: -- Install React Native dependencies --
echo.
echo [6/6] Setting up React Native app...
if not exist "mobile_app_rn\node_modules" (
    echo       Installing npm packages - first run, may take a few minutes...
    pushd mobile_app_rn
    npm install --legacy-peer-deps --no-audit
    popd
    echo       npm packages installed.
) else (
    echo       node_modules already exists.
)

:: -- Copy .env to mobile_app_rn if not present --
if not exist "mobile_app_rn\.env" (
    if exist ".env" (
        copy ".env" "mobile_app_rn\.env" >nul
        echo       Copied .env to mobile_app_rn\.env
    ) else (
        if exist "mobile_app_rn\.env.example" (
            copy "mobile_app_rn\.env.example" "mobile_app_rn\.env" >nul
            echo [WARNING] Created mobile_app_rn\.env from template.
            echo           Edit mobile_app_rn\.env with your EXPO_PUBLIC_* keys!
        )
    )
) else (
    echo       mobile_app_rn\.env found.
)

echo.
echo ================================================================
echo  Starting services...
echo ================================================================
echo.
echo  [Backend]  http://localhost:8000  (API docs: /docs)
echo  [Expo]     Scan QR code with Expo Go app on your phone
echo             OR press 'a' in the Expo terminal for Android emulator
echo.
echo  Press Ctrl+C in each window to stop.
echo ================================================================
echo.

:: -- Launch backend in a new window --
start "WageWise Backend" /d "%~dp0backend" cmd /k "call .venv\Scripts\activate.bat && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

:: -- Small delay then launch Expo --
timeout /t 2 /nobreak >nul
start "WageWise Expo" /d "%~dp0mobile_app_rn" cmd /k "npx expo start"

echo  Both services launched in separate windows.
echo  This window can be closed.
echo.
pause
endlocal
