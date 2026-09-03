@echo off
SetLocal EnableExtensions EnableDelayedExpansion
CLS

adb kill-server
adb start-server
echo [*] Waiting for device...
adb wait-for-device
adb.exe devices
adb root
adb remount
echo [*] Removing connection bridge...
adb reverse --remove tcp:27016
echo [*] Detecting game library path...
for /f "tokens=2 delims=:" %%p in ('adb shell pm path com.pubg.imobile') do (
    set APK_PATH=%%p
)

set APK_DIR=!APK_PATH!
set LIB_DIR=!APK_DIR:/base.apk=!/lib/arm

:: Handle case where it might be base.apk/..
if "!LIB_DIR!"=="!APK_DIR!" (
    set LIB_DIR=/data/app/com.pubg.imobile-1/lib/arm
)
echo [+] Target Lib Path: !LIB_DIR!


adb shell am force-stop com.pubg.imobile

echo [*] Pushing library to temporary location...
adb push "d:\Learning_C++\Floating-Mod-Menu-master\Floating-Mod-Menu-master\app\src\main\libs\armeabi-v7a\libGVoicePlugin.so" /data/local/tmp/libGVoicePlugin.so

echo [*] Copying library to game directory...
adb shell "cp /data/local/tmp/libGVoicePlugin.so !LIB_DIR!/libGVoicePlugin.so"
adb shell rm /data/local/tmp/libGVoicePlugin.so

adb shell rm -rf /sdcard/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs
adb shell rm -rf  /storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/logininfoFile.json

echo [*] Setting library permissions...
adb shell chmod 755 !LIB_DIR!/libGVoicePlugin.so
adb shell chown system:system !LIB_DIR!/libGVoicePlugin.so

echo [*] Launching BGMI...
adb shell am start -n com.pubg.imobile/com.epicgames.ue4.SplashActivity
adb shell sleep 10


