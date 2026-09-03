@echo off
setlocal enabledelayedexpansion

:: Configuration
set PACKAGE=com.pubg.imobile
set INJECTOR=inj32
set LIB2=libAkAudioVisiual.so
set LOCAL_PATH=D:\Learning_C++\Floating-Mod-Menu-master\Floating-Mod-Menu-master\app\src\main\libs\armeabi-v7a
set LOCAL_GVOICE=%LOCAL_PATH%\libAkAudioVisiual.so
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

:: Pushing GVoicePlugin
echo [*] Pushing GVoicePlugin...
if exist "%LOCAL_GVOICE%" (
    adb -s 127.0.0.1:%MUMU_PORT% push "%LOCAL_GVOICE%" %REMOTE_DIR%/%LIB2%
) else (
    echo [WARNING] %LOCAL_GVOICE% not found locally. Skipping push.
)

:: Check/Push Injector
for %%f in (%INJECTOR%) do (
    if exist "%%f" (
        echo [*] Pushing %%f from current folder...
        adb -s 127.0.0.1:%MUMU_PORT% push "%%f" %REMOTE_DIR%/%%f
    ) else if exist "%LOCAL_PATH%\%%f" (
        echo [*] Pushing %%f from libs directory...
        adb -s 127.0.0.1:%MUMU_PORT% push "%LOCAL_PATH%\%%f" %REMOTE_DIR%/%%f
    ) else (
        echo [!] %%f not found locally. Assumed already on device.
    )
)



:: Set permissions
echo [*] Setting permissions...
adb -s 127.0.0.1:%MUMU_PORT% shell "su -c 'chmod 755 %REMOTE_DIR%/%INJECTOR%'"

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
echo [+] libsigner.so detected.
echo [*] Waiting 2 seconds before proceeding...
timeout /t 2 >nul
echo [*] Proceeding with injection...

:: Injection


echo [*] Injecting %LIB2%...
adb -s 127.0.0.1:%MUMU_PORT% shell "su -c '%REMOTE_DIR%/%INJECTOR% --package %PACKAGE% --libs %REMOTE_DIR%/%LIB2%'"

:: Post-injection tasks

echo ==========================================
echo    Injection process finished!
echo ==========================================
pause
