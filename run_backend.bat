@echo off
setlocal enabledelayedexpansion
echo ============================================
echo  WageWise Backend - for Mobile Device
echo ============================================
echo.

REM ── Detect the LAN IP (Wi-Fi adapter) ──────────────────────────
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4 Address"') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    REM Skip VirtualBox / Hyper-V virtual adapters (192.168.56.x / 192.168.99.x)
    REM and Radmin VPN (26.x). Prefer 192.168.x.x and 172.x.x.x Wi-Fi addresses.
    echo !ip! | findstr /R "^192\.168\.56\." >nul && (set "ip=") || (
    echo !ip! | findstr /R "^26\."           >nul && (set "ip=") || (
        if not defined LANIP set "LANIP=!ip!"
    ))
)

if not defined LANIP set "LANIP=localhost"

echo Phone must be on the SAME Wi-Fi as this PC.
echo.
echo --------------------------------------------
echo  Backend URL for your phone's .env file:
echo.
echo    BACKEND_URL=http://%LANIP%:8000
echo.
echo  Test from phone browser:
echo    http://%LANIP%:8000/health
echo --------------------------------------------
echo.

REM ── Auto-write the detected LAN IP into .env, then sync to assets ──
REM (BACKEND_URL is baked into the APK at build time — after switching
REM  networks you must rebuild the app once: flutter run -d <device>)
if exist "%~dp0.env" (
    if not "%LANIP%"=="localhost" (
        powershell -NoProfile -Command "(Get-Content '%~dp0.env') -replace '^BACKEND_URL=.*', 'BACKEND_URL=http://%LANIP%:8000' | Set-Content -Encoding ascii '%~dp0.env'"
        echo BACKEND_URL updated to http://%LANIP%:8000 in .env
    )
    if not exist "%~dp0mobile_app\assets" mkdir "%~dp0mobile_app\assets"
    copy "%~dp0.env" "%~dp0mobile_app\assets\.env" >nul 2>&1
    echo .env synced to mobile_app\assets\
    echo.
    echo NOTE: if you changed Wi-Fi/hotspot since the last build, rebuild the
    echo phone app once:  cd mobile_app ^&^& flutter run -d R5CY207P8HZ
    echo.
)

echo Starting backend on http://0.0.0.0:8000 ...
echo (Press Ctrl+C to stop)
echo.

REM ── Launch backend bound to 0.0.0.0 so the phone can reach it ──
cd /d "%~dp0backend"
call .venv\Scripts\activate.bat
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
