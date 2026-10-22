param(
    [string]$Device = "fenix843mm"
)

# Builds the unit-test binary and runs it in the Connect IQ simulator.
# Exit code 0 = all tests passed.

Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force bin | Out-Null

& monkeyc -f monkey.jungle -o bin\test.prg -y developer_key -d $Device -t -w *> bin\test-build.log
if ($LASTEXITCODE -ne 0) {
    Get-Content bin\test-build.log
    Write-Host "TEST BUILD FAILED" -ForegroundColor Red
    exit 1
}

if (-not (Get-Process -Name "simulator" -ErrorAction SilentlyContinue)) {
    Start-Process "connectiq" -WindowStyle Hidden
    Start-Sleep -Seconds 6
}

$p = Start-Process -FilePath "monkeydo.bat" -ArgumentList "bin\test.prg", $Device, "/t" `
    -NoNewWindow -PassThru -RedirectStandardOutput "bin\test.out" -RedirectStandardError "bin\test.err"
if (-not $p.WaitForExit(180000)) {
    $p.Kill()
    Write-Host "TESTS TIMED OUT" -ForegroundColor Red
    exit 1
}

$out = Get-Content bin\test.out
$summary = $out | Select-String -Pattern "^(PASSED|FAILED) \(passed="
$failures = $out | Select-String -Pattern "\s(FAIL|ERROR)$"
$failures | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
if ($summary) { Write-Host $summary.Line }

if ($summary -and $summary.Line.StartsWith("PASSED")) {
    Write-Host "ALL TESTS PASSED" -ForegroundColor Green
    exit 0
}
$out | Select-String -Pattern "ASSERT|Exception|Error" | Select-Object -First 20 | ForEach-Object { $_.Line }
Write-Host "TESTS FAILED" -ForegroundColor Red
exit 1
