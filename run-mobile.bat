@echo off
echo ============================================
echo  WageWise - Starting App on Mobile Device
echo ============================================
echo.

REM Sync .env to Flutter assets so dotenv can load it on device
if exist "%~dp0.env" (
    if not exist "%~dp0mobile_app\assets" mkdir "%~dp0mobile_app\assets"
    copy "%~dp0.env" "%~dp0mobile_app\assets\.env" >nul 2>&1
)

REM Start Python backend bound to 0.0.0.0 so phones on the same Wi-Fi can reach it
echo Starting Python backend on http://0.0.0.0:8000 ...
start "WageWise Backend" cmd /k "cd /d "%~dp0backend" && call .venv\Scripts\activate.bat && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

timeout /t 3 /nobreak >nul

echo.
echo --------------------------------------------
echo  Connected devices:
echo --------------------------------------------
cd /d "%~dp0mobile_app"
flutter devices
echo.
echo --------------------------------------------
echo  Backend URL hint:
echo   - Android emulator: env.dart auto-rewrites localhost to 10.0.2.2
echo   - iOS simulator:    localhost works as-is
echo   - Physical phone:   set BACKEND_URL=http://YOUR_LAN_IP:8000 in .env
echo                       (phone must be on the same Wi-Fi network)
echo --------------------------------------------
echo.
echo Pick a device ID from above, then run:
echo   cd mobile_app
echo   flutter run -d ^<device-id^>
echo.
echo Or just press Enter to launch on the first available mobile device.
pause

flutter run
