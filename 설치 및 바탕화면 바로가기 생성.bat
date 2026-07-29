@echo off
chcp 65001 > nul
title PC PowerSaver Pro - 바탕화면 바로가기 생성기

echo ======================================================
echo   PC PowerSaver Pro - 바탕화면 및 시작 메뉴 바로가기 설치
echo ======================================================
echo.

set TARGET_DIR=%~dp0
@echo off
chcp 65001 > nul
title PC PowerSaver Pro - 바탕화면 및 시작프로그램 등록기

echo ======================================================
echo  PC PowerSaver Pro - 바탕화면 바로가기 및 시작프로그램 등록
echo ======================================================
echo.

:: 현재 배치 파일이 있는 경로를 변수로 지정
set TARGET_DIR=%~dp0
set TARGET_BAT=%TARGET_DIR%Run_PowerSaver.bat
set SCRIPT_PATH=%TARGET_DIR%create_lnk.ps1

echo [1/2] 바로가기 및 등록 스크립트 작성 중...
(
echo $WshShell = New-Object -ComObject WScript.Shell
echo $DesktopPath = [System.Environment]::GetFolderPath('Desktop')
echo $StartupPath = [System.Environment]::GetFolderPath('Startup')
echo.
echo # 1. 바탕화면 바로가기 생성
echo $DesktopShortcutPath = Join-Path $DesktopPath "PC PowerSaver Pro.lnk"
echo $DesktopShortcut = $WshShell.CreateShortcut($DesktopShortcutPath)
echo $DesktopShortcut.TargetPath = "%TARGET_BAT%"
echo $DesktopShortcut.WorkingDirectory = "%TARGET_DIR%"
echo $DesktopShortcut.Description = "PC PowerSaver Pro - 절전 및 전원 관리 프로그램"
echo $DesktopShortcut.IconLocation = "shell32.dll,27"
echo $DesktopShortcut.Save()
echo Write-Host "✅ 바탕화면 바로가기가 성공적으로 생성되었습니다."
echo.
echo # 2. 시작프로그램 등록 (부팅 시 자동 실행)
echo $StartupShortcutPath = Join-Path $StartupPath "PC PowerSaver Pro.lnk"
echo $StartupShortcut = $WshShell.CreateShortcut($StartupShortcutPath)
echo $StartupShortcut.TargetPath = "%TARGET_BAT%"
echo $StartupShortcut.WorkingDirectory = "%TARGET_DIR%"
echo $StartupShortcut.Description = "PC PowerSaver Pro - 절전 및 전원 관리 프로그램"
echo $StartupShortcut.IconLocation = "shell32.dll,27"
echo $StartupShortcut.Save()
echo Write-Host "✅ 시작프로그램(부팅 시 자동 실행) 등록이 완료되었습니다."
) > "%SCRIPT_PATH%"

echo [2/2] 바로가기 생성 실행 중...
echo.
powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"
del "%SCRIPT_PATH%" > nul 2>&1

echo.
echo ======================================================
echo  설치가 완료되었습니다! 
echo  - 바탕화면에서 'PC PowerSaver Pro'를 더블 클릭하여 실행할 수 있습니다.
echo  - 이제 PC 부팅 시 프로그램이 자동으로 실행됩니다.
echo ======================================================
echo.
pause