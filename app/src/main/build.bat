@cls
@echo off

set NDK_OUT=D:/testbro

set NDK_PROJECT_PATH=%~dp0
set NDK_APPLICATION_MK=%NDK_PROJECT_PATH%jni\Application.mk

D:\ndkllvm\build\ndk-build NDK_OUT=%NDK_OUT% NDK_PROJECT_PATH=%NDK_PROJECT_PATH% NDK_APPLICATION_MK=%NDK_APPLICATION_MK%

set
pause
