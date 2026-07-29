# PC PowerSaver Pro - Desktop & Startup Shortcut Creator Script
# UTF-8 Encoding

$ws = New-Object -ComObject WScript.Shell
$desktop = [System.Environment]::GetFolderPath('Desktop')
$startup = [System.Environment]::GetFolderPath('Startup')

$targetBat = Join-Path $PSScriptRoot "Run_PowerSaver.bat"
if (-not $PSScriptRoot -or -not (Test-Path $PSScriptRoot)) {
    $targetBat = "c:\Users\jkiso\Documents\test\Run_PowerSaver.bat"
}

$workDir = $PSScriptRoot
if (-not $workDir) {
    $workDir = "c:\Users\jkiso\Documents\test"
}

# 1. Desktop Shortcut Creation
$desktopShortcutPath = Join-Path $desktop "PC PowerSaver Pro.lnk"
$s1 = $ws.CreateShortcut($desktopShortcutPath)
$s1.TargetPath = $targetBat
$s1.WorkingDirectory = $workDir
$s1.Description = "PC PowerSaver Pro - 절전 및 전원 관리 프로그램"
$s1.IconLocation = "shell32.dll,27"
$s1.Save()
Write-Host "바탕화면 바로가기가 성공적으로 생성되었습니다: $desktopShortcutPath"

# 2. Windows Startup Folder Shortcut Creation (자동 실행 등록)
$startupShortcutPath = Join-Path $startup "PC PowerSaver Pro.lnk"
$s2 = $ws.CreateShortcut($startupShortcutPath)
$s2.TargetPath = $targetBat
$s2.WorkingDirectory = $workDir
$s2.Description = "PC PowerSaver Pro - 윈도우 시작 시 자동 실행"
$s2.IconLocation = "shell32.dll,27"
$s2.Save()
Write-Host "윈도우 시작 프로그램(Startup) 바로가기가 성공적으로 생성되었습니다: $startupShortcutPath"
