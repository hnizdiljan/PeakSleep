#!/usr/bin/env powershell

# Script pro kontrolu logů z Connect IQ simulátoru
Write-Host "Kontrolujem logy z Connect IQ simulatoru..." -ForegroundColor Cyan

# Cesty k možným log souborům
$possibleLogPaths = @(
    "$env:TEMP\ConnectIQ\*.log",
    "$env:LOCALAPPDATA\Garmin\ConnectIQ\Logs\*.log",
    "$env:APPDATA\Garmin\ConnectIQ\Logs\*.log",
    "C:\Garmin\ConnectIQ\logs\*.log",
    "$env:USERPROFILE\AppData\Local\Garmin\ConnectIQ\logs\*.log"
)

$foundLogs = $false

foreach ($logPath in $possibleLogPaths) {
    $logFiles = Get-ChildItem $logPath -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    
    if ($logFiles) {
        $foundLogs = $true
        Write-Host "Nalezeny logy v: $(Split-Path $logPath -Parent)" -ForegroundColor Green
        
        $latestLog = $logFiles[0]
        Write-Host "Nejnovejsi log: $($latestLog.Name)" -ForegroundColor Yellow
        
        # Zobraz posledních 30 řádků z nejnovějšího logu
        Write-Host "`n--- Posledních 30 řádků z $($latestLog.Name) ---" -ForegroundColor Cyan
        Get-Content $latestLog.FullName -Tail 30
        Write-Host "--- Konec logu ---`n" -ForegroundColor Cyan
        break
    }
}

if (-not $foundLogs) {
    Write-Host "Nebyly nalezeny žádné log soubory" -ForegroundColor Yellow
    Write-Host "Mozna reseni:" -ForegroundColor Cyan
    Write-Host "   1. Ověřte, že simulátor běží" -ForegroundColor White
    Write-Host "   2. Zkuste spustit aplikaci znovu" -ForegroundColor White
    Write-Host "   3. Zkontrolujte manifest.xml" -ForegroundColor White
}

# Zkontroluj běžící Connect IQ procesy
Write-Host "Kontrolujem bezici Connect IQ procesy..." -ForegroundColor Cyan
$ciqProcesses = Get-Process | Where-Object {$_.ProcessName -like "*connect*" -or $_.ProcessName -like "*simulator*" -or $_.ProcessName -like "*monkey*"}

if ($ciqProcesses) {
    Write-Host "Nalezene Connect IQ procesy:" -ForegroundColor Green
    $ciqProcesses | Format-Table ProcessName, Id, CPU -AutoSize
} else {
    Write-Host "Zadne Connect IQ procesy nebezi" -ForegroundColor Red
}

Write-Host "`n💡 Pro zobrazení aktuálních logů v reálném čase:" -ForegroundColor Yellow
Write-Host "   .\check_logs.ps1" -ForegroundColor White 