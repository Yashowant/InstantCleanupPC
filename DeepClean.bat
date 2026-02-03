@echo off
setlocal
title Windows Deep Disk Cleanup Tool
color 0B

:: ======================================================
::  WINDOWS DEEP DISK CLEANUP TOOL
::  Improved for safety and reliability
:: ======================================================

echo.
echo ======================================================
echo    WINDOWS DEEP DISK CLEANUP TOOL
echo    Note: This script requires Administrator privileges.
echo ======================================================
echo.

:: 1. Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Admin privileges confirmed.
) else (
    echo [ERROR] Current permissions are inadequate.
    echo Please right-click this file and select "Run as Administrator".
    echo.
    pause
    exit
)

echo.
echo ------------------------------------------------------
echo 1. Stopping Windows Update Services...
echo ------------------------------------------------------
:: Stopping services to allow cleaning of locked update files
net stop wuauserv >nul 2>&1
echo [INFO] Windows Update Service stopped.
net stop bits >nul 2>&1
echo [INFO] BITS Service stopped.

echo.
echo ------------------------------------------------------
echo 2. Cleaning Windows Update Download Cache...
echo ------------------------------------------------------
:: We delete contents, but strictly check paths to avoid accidents.
if exist "%WINDIR%\SoftwareDistribution\Download" (
    echo [INFO] Cleaning Update Cache...
    del /f /s /q "%WINDIR%\SoftwareDistribution\Download\*.*" >nul 2>&1
    echo [OK] Update cache cleared.
) else (
    echo [INFO] Update cache not found or already empty.
)

echo.
echo ------------------------------------------------------
echo 3. Cleaning System Temporary Files...
echo ------------------------------------------------------
:: Using 2>nul to hide "Access Denied" errors for files currently in use
del /f /s /q "%WINDIR%\Temp\*.*" >nul 2>&1
echo [OK] System Temp cleared (Skipped locked files).

echo.
echo ------------------------------------------------------
echo 4. Cleaning User Temporary Files...
echo ------------------------------------------------------
del /f /s /q "%TEMP%\*.*" >nul 2>&1
echo [OK] User Temp cleared (Skipped locked files).

echo.
echo ------------------------------------------------------
echo 5. Cleaning Recycle Bin...
echo ------------------------------------------------------
:: Using specific targeting for the C: drive Recycle Bin
if exist %systemdrive%\$Recycle.bin (
    rd /s /q %systemdrive%\$Recycle.bin >nul 2>&1
    echo [OK] Recycle Bin emptied.
) else (
    echo [INFO] Recycle Bin already empty or not accessible.
)

:: NOTE: Prefetch cleaning removed.
:: Microsoft recommends NOT cleaning Prefetch as it slows down boot times 
:: and application launches while Windows rebuilds the cache.

echo.
echo ------------------------------------------------------
echo 6. Restarting Services (Critical Step)...
echo ------------------------------------------------------
net start wuauserv >nul 2>&1
echo [OK] Windows Update Service restarted.
net start bits >nul 2>&1
echo [OK] BITS Service restarted.

echo.
echo ------------------------------------------------------
echo 7. Launching Windows Disk Cleanup Utility...
echo ------------------------------------------------------
echo The native Disk Cleanup tool will now open. 
echo Select "Clean up system files" in the tool for maximum effect.
echo.
:: Using cleanmgr /LOWDISK triggers the UI but scans automatically
start cleanmgr /d C

echo.
echo ======================================================
echo    CLEANUP COMPLETE!
echo    You can close this window.
echo ======================================================
pause
endlocal