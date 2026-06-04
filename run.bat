@echo off
echo ============================================
echo  WageWise - Starting Application
echo ============================================
echo.

REM Sync .env to Flutter assets
if exist "%~dp0.env" (
    if not exist "%~dp0mobile_app\assets" mkdir "%~dp0mobile_app\assets"
    copy "%~dp0.env" "%~dp0mobile_app\assets\.env" >nul 2>&1
)

REM Start Python backend
echo Starting Python backend on http://localhost:8000 ...
start "WageWise Backend" cmd /k "cd /d "%~dp0backend" && call .venv\Scripts\activate.bat && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

REM Wait for backend to start
timeout /t 3 /nobreak >nul

REM Start Flutter web
echo Starting Flutter web app on Chrome...
start "WageWise Flutter" cmd /k "cd /d "%~dp0mobile_app" && flutter run -d chrome"

echo.
echo Both services are starting in separate windows.
echo Backend:  http://localhost:8000
echo Frontend: Flutter will open Chrome automatically
echo.
echo Press any key to close this window (services keep running).
pause >nul
