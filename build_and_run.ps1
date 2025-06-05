#!/usr/bin/env powershell

# Build and Run script for PeakSleep Connect IQ widget
# Automatický build a spuštění PeakSleep aplikace

Write-Host "🔧 Buildování PeakSleep aplikace..." -ForegroundColor Cyan

# Build aplikace pomocí monkey.jungle
$buildResult = & monkeyc -f monkey.jungle -o PeakSleep.prg -y developer_key -d fenix7 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build selhal!" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build úspěšný!" -ForegroundColor Green

# Zkontrolujeme, zda běží simulator
$simulatorProcess = Get-Process -Name "simulator" -ErrorAction SilentlyContinue

if (-not $simulatorProcess) {
    Write-Host "🚀 Spouštím Connect IQ Simulator..." -ForegroundColor Yellow
    Start-Process "connectiq" -ArgumentList "-d", "fenix7" -NoNewWindow
    Start-Sleep -Seconds 3
} else {
    Write-Host "✅ Simulator již běží" -ForegroundColor Green
}

# Spustíme aplikaci v emulátoru
Write-Host "📱 Načítám PeakSleep do emulátoru..." -ForegroundColor Cyan
$runResult = & connectiq --device fenix7 --run PeakSleep.prg 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Spuštění v emulátoru selhalo!" -ForegroundColor Red
    Write-Host $runResult -ForegroundColor Red
    exit 1
}

Write-Host "🎉 PeakSleep úspěšně načten do emulátoru!" -ForegroundColor Green
Write-Host "💡 Tip: Emulátor můžete ovládat pomocí myši a klávesnice" -ForegroundColor Yellow 