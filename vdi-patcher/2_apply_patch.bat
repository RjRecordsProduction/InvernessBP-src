@echo off
:: ============================================================
::  HDiffPatch - APPLY PATCH
::  Patches system.vdi (new) → restores old version as system.vdi
::  User does NOT need the old VDI. Only needs system.vdi + patch.
:: ============================================================

set ROOT=%~dp0

set TOOLS=%ROOT%tools
set VDI_DIR=C:\MuMuPlayerGlobal\nx_device\12.0\vms\MuMuPlayerGlobal-12.0-base
set BASE_VDI=%VDI_DIR%\system.vdi
set TEMP_VDI=%VDI_DIR%\system_patched_temp.vdi
set BACKUP_VDI=%VDI_DIR%\system_new_backup.vdi
set PATCH=%ROOT%system_new_to_old.patch

echo.
echo  [HDiffPatch] Restoring old system.vdi using patch...
echo  Base   : %BASE_VDI%
echo  Patch  : %PATCH%
echo  Output : %BASE_VDI%  (replaces current)
echo.

:: Checks
if not exist "%BASE_VDI%" (
    echo  [ERROR] system.vdi not found: %BASE_VDI%
    echo  Make sure MuMu Player is installed.
    pause & exit /b 1
)
if not exist "%PATCH%" (
    echo  [ERROR] Patch file not found: %PATCH%
    echo  Place system_new_to_old.patch next to this script.
    pause & exit /b 1
)

:: Clean up any leftover temp from a previous failed run
if exist "%TEMP_VDI%" del /f /q "%TEMP_VDI%"

:: Step 1: Patch system.vdi → temp file
echo  [1/3] Applying patch to temp file...
"%TOOLS%\hpatchz.exe" "%BASE_VDI%" "%PATCH%" "%TEMP_VDI%"

if not %ERRORLEVEL% == 0 (
    echo.
    echo  [ERROR] hpatchz failed. system.vdi was NOT changed.
    if exist "%TEMP_VDI%" del /f /q "%TEMP_VDI%"
    pause & exit /b 1
)

:: Step 2: Backup the current (new) system.vdi
echo  [2/3] Backing up current system.vdi as system_new_backup.vdi...
if exist "%BACKUP_VDI%" del /f /q "%BACKUP_VDI%"
ren "%BASE_VDI%" system_new_backup.vdi

:: Step 3: Rename temp → system.vdi
echo  [3/3] Renaming patched file to system.vdi...
ren "%TEMP_VDI%" system.vdi

echo.
echo  [OK] Done! Old VDI is now active as system.vdi
echo  Backup of new VDI kept as: system_new_backup.vdi
for %%F in ("%BASE_VDI%") do echo  Size: %%~zF bytes
echo.
echo  To revert back to the new VDI, run: 3_restore_new.bat
echo.
pause
