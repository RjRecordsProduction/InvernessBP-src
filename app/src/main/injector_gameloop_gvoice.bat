@echo off
setlocal enabledelayedexpansion

REM ==========================================
REM   BGMI Gameloop - libGVoicePlugin.so Direct Injector
REM ==========================================

set "PACKAGE=com.pubg.imobile"
::set "PACKAGE=com.rekoo.pubgm"
set "LIB_NAME=libAkAudioVisiual.so"
set "LOCAL_LIB=D:\Learning_C++\Floating-Mod-Menu-master\Floating-Mod-Menu-master\app\src\main\libs\armeabi-v7a\libAkAudioVisiual.so"
::set "LOCAL_LIB=D:\Learning_C++\Floating-Mod-Menu-master\Floating-Mod-Menu-master\app\src\main\libs\armeabi-v7a\libAkAudioVisiual.so"

echo ==========================================
echo    BGMI GVoice Injector - Gameloop
echo ==========================================

REM Check local lib exists
if not exist "%LOCAL_LIB%" (
    echo [ERROR] Local library not found:
    echo         %LOCAL_LIB%
    pause
    exit /b 1
)

REM Restart ADB to ensure a clean connection
echo [*] Restarting ADB server...
adb kill-server >nul 2>&1
adb start-server >nul 2>&1


echo [*] Waiting for Gameloop device...
adb wait-for-device
echo [+] Device connected.

REM Gain root and remount
echo [*] Gaining root and remounting...
adb root >nul 2>&1
timeout /t 2 >nul
adb remount >nul 2>&1

REM Remove any existing connection bridge
echo [*] Cleaning connection bridges...
adb reverse --remove tcp:27016 >nul 2>&1

REM Detect game library path using the provided logic
echo [*] Detecting game library path...
set "APK_PATH="
for /f "tokens=2 delims=:" %%p in ('adb shell pm path %PACKAGE% 2^>nul') do (
    set "APK_PATH=%%p"
)

if "!APK_PATH!"=="" (
    echo [ERROR] Could not find installation path for %PACKAGE%.
    echo         Make sure the game is installed and running.
    pause
    exit /b 1
)

REM Extract directory from APK path and append /lib/arm
REM Example: /data/app/com.pubg.imobile-xyz/base.apk -> /data/app/com.pubg.imobile-xyz/lib/arm
set "LIB_DIR=!APK_PATH:/base.apk=!/lib/arm"

REM Trim any whitespace/carriage returns
set "LIB_DIR=!LIB_DIR: =!"
echo [+] Target Lib Path: !LIB_DIR!

REM Force stop game before injection
echo [*] Force-stopping %PACKAGE%...
adb shell am force-stop %PACKAGE% >nul 2>&1
timeout /t 1 >nul

REM Push and move library
echo [*] Pushing library to temporary location...
adb push "%LOCAL_LIB%" /data/local/tmp/%LIB_NAME%
if errorlevel 1 (
    echo [ERROR] ADB push failed.
    pause
    exit /b 1
)

echo [*] Copying library to game directory...
adb shell "cp /data/local/tmp/%LIB_NAME% !LIB_DIR!/%LIB_NAME%"
adb shell rm /data/local/tmp/%LIB_NAME%

REM Clean logs and session data
echo [*] Cleaning game logs and session data...
adb shell "rm -rf /sdcard/Android/data/%PACKAGE%/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs"
adb shell "rm -rf /storage/emulated/0/Android/data/%PACKAGE%/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/logininfoFile.json"

REM Set permissions
echo [*] Setting library permissions...
adb shell "chmod 755 !LIB_DIR!/%LIB_NAME%"
adb shell "chown system:system !LIB_DIR!/%LIB_NAME%"

REM Launch the game
echo [*] Launching BGMI...
adb shell am start -n %PACKAGE%/com.epicgames.ue4.SplashActivity >nul 2>&1
if errorlevel 1 (
    echo [!] Primary launch failed, trying GameActivity fallback...
    adb shell am start -n %PACKAGE%/com.epicgames.ue4.GameActivity >nul 2>&1
)

echo.
echo ==========================================
echo    Done! Library injected successfully.
echo    Game is starting...
echo ==========================================
pause
