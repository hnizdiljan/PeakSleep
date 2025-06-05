param(
    [string]$Device = "fenix843mm",
    [switch]$Help
)

# Build and Run script for PeakSleep Connect IQ widget

if ($Help) {
    Write-Host "Pouziti: .\build_and_run.ps1 [-Device <nazev_zarizeni>] [-Help]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Parametry:" -ForegroundColor Cyan
    Write-Host "  -Device    Nazev zarizeni pro emulaciu (default: fenix843mm)" -ForegroundColor White
    Write-Host "  -Help      Zobrazi tuto napovedu" -ForegroundColor White
    Write-Host ""
    Write-Host "Priklad:" -ForegroundColor Cyan
    Write-Host "  .\build_and_run.ps1 -Device fenix7" -ForegroundColor White
    Write-Host "  .\build_and_run.ps1 -Device vivoactive4" -ForegroundColor White
    exit 0
}

Write-Host "Building PeakSleep aplikace pro $Device..." -ForegroundColor Cyan

$buildResult = & monkeyc -f monkey.jungle -o PeakSleep.prg -y developer_key -d $Device 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build selhal!" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}

Write-Host "Build uspesny!" -ForegroundColor Green

$connectiqProcess = Get-Process -Name "connectiq" -ErrorAction SilentlyContinue

if (-not $connectiqProcess) {
    Write-Host "Spoustim ConnectIQ server..." -ForegroundColor Yellow
    Start-Process "connectiq" -NoNewWindow -PassThru
    Start-Sleep -Seconds 3
    Write-Host "ConnectIQ server spusten" -ForegroundColor Green
} else {
    Write-Host "ConnectIQ server jiz bezi" -ForegroundColor Green
}

Write-Host "Spoustim emulator pro $Device pres monkeydo..." -ForegroundColor Cyan
$emulatorResult = & monkeydo PeakSleep.prg $Device 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Spusteni emulatoru selhalo!" -ForegroundColor Red
    Write-Host $emulatorResult -ForegroundColor Red
    
    Write-Host "Zkousim alternativni zpusob..." -ForegroundColor Yellow
    $altResult = & connectiq --device $Device --run PeakSleep.prg 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Alternativni spusteni selhalo!" -ForegroundColor Red
        Write-Host $altResult -ForegroundColor Red
        exit 1
    }
}

Write-Host "PeakSleep uspesne nacten do emulatoru $Device!" -ForegroundColor Green
Write-Host "Tip: Emulator muzete ovladat pomoci mysi a klavesnice" -ForegroundColor Yellow 