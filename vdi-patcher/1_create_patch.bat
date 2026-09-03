@echo off
:: ============================================================
::  HDiffPatch - CREATE PATCH
::  Run this ONCE on the machine that has BOTH VDI files.
::  Rename new VDI to system.vdi and old VDI to system_old.vdi
::  Output: a small .patch file you can share/store.
:: ============================================================

:: Get this script's directory so paths are always relative to it
set ROOT=%~dp0

set TOOLS=%ROOT%tools
set VDI_DIR=C:\MuMuPlayerGlobal\nx_device\12.0\vms\MuMuPlayerGlobal-12.0-base
set OLD_VDI=%VDI_DIR%\system_old.vdi
set NEW_VDI=%VDI_DIR%\system.vdi
set OUT_PATCH=%ROOT%system_new_to_old.patch

echo.
echo  [HDiffPatch] Creating patch: system.vdi --^> system_old.vdi
echo  Source  : %NEW_VDI%
echo  Target  : %OLD_VDI%
echo  Output  : %OUT_PATCH%
echo.

if not exist "%NEW_VDI%" ( echo  [ERROR] system.vdi not found! & pause & exit /b 1 )
if not exist "%OLD_VDI%" ( echo  [ERROR] system_old.vdi not found!  & pause & exit /b 1 )

:: -WD = whole-file diff (best for large binary blobs like VDI)
:: -s-64 = 64-byte match step
:: -c-zstd-21-24 = max zstd compression
"%TOOLS%\hdiffz.exe" "%NEW_VDI%" "%OLD_VDI%" "%OUT_PATCH%" -WD -s-64 -c-zstd-21-24

if %ERRORLEVEL% == 0 (
    echo.
    echo  [OK] Patch created!
    for %%F in ("%OUT_PATCH%") do echo  Size: %%~zF bytes
    echo  Share this .patch file + hpatchz.exe + 2_apply_patch.bat
) else (
    echo.
    echo  [ERROR] hdiffz failed. Exit code: %ERRORLEVEL%
)

echo.
pause
