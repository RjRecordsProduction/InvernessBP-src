@echo off

rem NDK location
set NDK=C:\ndk\build

rem path to JNI
set PROJECT=%cd%\app\src\main

"%NDK%\ndk-build.cmd" ^
 NDK_PROJECT_PATH=%PROJECT% ^
 APP_BUILD_SCRIPT=%PROJECT%\jni\Android.mk ^
 NDK_APPLICATION_MK=%PROJECT%\jni\Application.mk ^
 -j8

pause
