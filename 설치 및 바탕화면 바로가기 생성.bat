@echo off
title PC PowerSaver Pro - Shortcut Installer
echo ======================================================
echo   PC PowerSaver Pro - Installing Desktop Shortcut...
echo ======================================================
echo.
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0create_shortcut.ps1"
echo.
echo ======================================================
echo  Installation Complete! 
echo  Double-click 'PC PowerSaver Pro' shortcut on Desktop.
echo ======================================================
echo.
pause