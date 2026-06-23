@echo off
echo ============================================
echo  WageWise - Restarting Backend
echo ============================================

REM Kill anything already on port 8000
echo Stopping any process on port 8000...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8000" ^| find "LISTENING" 2^>nul') do (
    taskkill /PID %%a /F >nul 2>&1
)
timeout /t 1 /nobreak >nul

REM Start fresh using python -m uvicorn (works even if uvicorn not in global PATH)
echo Starting backend...
start "WageWise Backend" cmd /k "cd /d "%~dp0backend" && call .venv\Scripts\activate.bat && python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

echo.
echo Backend restarting in a new window.
echo URL: http://localhost:8000
echo Wait a few seconds then refresh the app.
timeout /t 2 /nobreak >nul
