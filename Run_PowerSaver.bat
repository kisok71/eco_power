@echo off
chcp 65001 > nul
title PC PowerSaver Pro - Launcher
echo Starting PC PowerSaver Pro...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0PowerSaver.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Execution failed. Retrying with visible console for error logging...
    powershell -ExecutionPolicy Bypass -NoExit -File "%~dp0PowerSaver.ps1"
)
