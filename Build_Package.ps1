# PC PowerSaver Pro - Distribution Packaging Script
$SourceDir = "c:\Users\jkiso\Documents\test"
$ZipPath = "c:\Users\jkiso\Documents\test\PC_PowerSaver_Pro_v1.0.zip"

Write-Host "PC PowerSaver Pro 배포용 압축 파일(ZIP) 생성을 시작합니다..."

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

$TempFolder = Join-Path $env:TEMP "PC_PowerSaver_Pro"
if (Test-Path $TempFolder) {
    Remove-Item $TempFolder -Recurse -Force
}
New-Item -ItemType Directory -Path $TempFolder | Out-Null

$Files = Get-ChildItem -Path $SourceDir -File | Where-Object { 
    $_.Extension -in @(".ps1", ".bat", ".html", ".css", ".js", ".md") -and $_.Name -ne "Build_Package.ps1"
}

foreach ($f in $Files) {
    Copy-Item -Path $f.FullName -Destination $TempFolder -Force
    Write-Host "포함됨: $($f.Name)"
}

Compress-Archive -Path "$TempFolder\*" -DestinationPath $ZipPath -CompressionLevel Optimal
Remove-Item $TempFolder -Recurse -Force

Write-Host "======================================================"
Write-Host "배포용 ZIP 패키지 생성 완료!"
Write-Host "저장 위치: $ZipPath"
Write-Host "======================================================"
