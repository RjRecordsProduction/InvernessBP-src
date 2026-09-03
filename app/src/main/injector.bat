@echo off
setlocal enabledelayedexpansion

:: Configuration
set PACKAGE=com.pubg.imobile
set INJECTOR=inj32
set LIB1=libAkAudioVisiual.so
set LOCAL_PATH=C:\Users\Maddy\Documents\Documents\InvernessVIP\InvernessVIP
set REMOTE_DIR=/data/local/tmp

:: MuMu Player ADB port (default 16384, adjust if needed)
set MUMU_PORT=7555

echo ==========================================
echo    BGMI Library Injector (AndKitty) - MuMu
echo ==========================================

:: Connect to MuMu Player via ADB
echo [*] Connecting to MuMu Player (port %MUMU_PORT%)...
adb connect 127.0.0.1:%MUMU_PORT% >nul 2>&1
timeout /t 2 >nul

:: Check ADB connection
adb -s 127.0.0.1:%MUMU_PORT% get-state >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Could not connect to MuMu Player on port %MUMU_PORT%.
    echo [INFO]  Make sure MuMu Player is running and ADB is enabled.
    pause
    exit /b
)
echo [+] Connected to MuMu Player.

:: Start Game
echo [*] Starting BGMI (%PACKAGE%)...
adb -s 127.0.0.1:%MUMU_PORT% shell monkey -p %PACKAGE% -c android.intent.category.LAUNCHER 1 >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to start game automatically. Please start it manually.
)

:: Pushing Libraries
echo [*] Pushing %LIB1%...
if exist "%LOCAL_PATH%\%LIB1%" (
    adb -s 127.0.0.1:%MUMU_PORT% push "%LOCAL_PATH%\%LIB1%" %REMOTE_DIR%/%LIB1%
) else (
    echo [WARNING] %LIB1% not found in %LOCAL_PATH%.
)

echo [*] Pushing %LIB2%...
if exist "%LOCAL_PATH%\%LIB2%" (
    adb -s 127.0.0.1:%MUMU_PORT% push "%LOCAL_PATH%\%LIB2%" %REMOTE_DIR%/%LIB2%
) else (
    echo [WARNING] %LIB2% not found in %LOCAL_PATH%.
)

:: Check/Push Injector
if exist "%INJECTOR%" (
    echo [*] Pushing %INJECTOR% from current folder...
    adb -s 127.0.0.1:%MUMU_PORT% push "%INJECTOR%" %REMOTE_DIR%/%INJECTOR%
) else if exist "%LOCAL_PATH%\%INJECTOR%" (
    echo [*] Pushing %INJECTOR% from libs directory...
    adb -s 127.0.0.1:%MUMU_PORT% push "%LOCAL_PATH%\%INJECTOR%" %REMOTE_DIR%/%INJECTOR%
)

:: Set permissions
echo [*] Setting permissions...
adb -s 127.0.0.1:%MUMU_PORT% shell "su -c 'chmod 755 %REMOTE_DIR%/%INJECTOR%'"
adb -s 127.0.0.1:%MUMU_PORT% shell "su -c 'chmod 755 %REMOTE_DIR%/%LIB1%'"
adb -s 127.0.0.1:%MUMU_PORT% shell "su -c 'chmod 755 %REMOTE_DIR%/%LIB2%'"

echo [*] Waiting for %PACKAGE% to start...
:wait_app
set PID=
for /f "tokens=1" %%i in ('adb -s 127.0.0.1:%MUMU_PORT% shell "pidof %PACKAGE%"') do set PID=%%i
if "!PID!"=="" (
    timeout /t 1 >nul
    goto wait_app
)
echo [+] Process %PACKAGE% found (PID: !PID!)

echo [*] Waiting for libsigner.so to be loaded...
:wait_signer
set SIGNER=
for /f "tokens=*" %%i in ('adb -s 127.0.0.1:%MUMU_PORT% shell "su -c 'grep libsigner.so /proc/!PID!/maps'"') do set SIGNER=%%i
if "!SIGNER!"=="" (
    timeout /t 2 >nul
    goto wait_signer
)
echo [+] libsigner.so detected. Proceeding with injection...

:: Injection

echo ==========================================
echo    Injection process finished!
echo ==========================================
pause
