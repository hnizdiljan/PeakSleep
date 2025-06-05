# Návod na instalace Connect IQ SDK pro PeakSleep

## Metoda 1: Oficiální instalace (Doporučeno)

### 1. Stažení SDK
1. Jděte na: https://developer.garmin.com/connect-iq/sdk/
2. Stáhněte "Connect IQ SDK" pro Windows
3. Stáhněte také "Connect IQ Device Simulator"

### 2. Instalace
1. Spusťte stažený instalátor jako administrátor
2. Nechte výchozí cestu instalace: `C:\Garmin\ConnectIQ`
3. Dokončete instalaci

### 3. Nastavení PATH
Po instalaci musíte přidat SDK do PATH:

```powershell
# Otevřete PowerShell jako administrátor a spusťte:
$sdkPath = "C:\Garmin\ConnectIQ\bin"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
if ($currentPath -notlike "*$sdkPath*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$sdkPath", "Machine")
    Write-Host "✅ Connect IQ SDK přidáno do PATH"
}
```

### 4. Restart terminolu
Zavřete a znovu otevřete PowerShell/CMD, aby se načetl nový PATH.

### 5. Ověření instalace
```powershell
monkeyc --version
connectiq --version
```

## Metoda 2: VS Code Extension (Jednodušší)

### 1. Instalace Monkey C Extension
1. Otevřete VS Code
2. Jděte do Extensions (Ctrl+Shift+X)
3. Vyhledejte "Monkey C" od Garmin
4. Nainstalujte

### 2. Automatická konfigurace
Extension automaticky:
- Stáhne a nastaví Connect IQ SDK
- Nakonfiguruje kompiler
- Nastaví emulator

### 3. Použití
- **F5** - Build a spuštění v emulátoru
- **Ctrl+Shift+P** → "Monkey C: Build for Device"

## Metoda 3: Chocolatey (Pro pokročilé)

```powershell
# Nejprve nainstalujte Chocolatey (pokud nemáte):
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Poté nainstalujte Connect IQ:
choco install garmin-connect-iq
```

## Řešení problémů

### Problem: "monkeyc not found"
```powershell
# Zjistěte, kde je SDK nainstalováno:
Get-ChildItem "C:\Garmin" -Recurse -Name "monkeyc.exe" -ErrorAction SilentlyContinue

# Pokud najdete, přidejte cestu do PATH

```

### Problem: "Java not found"
Connect IQ vyžaduje Java 8+:
```powershell
# Zkontrolujte Java:
java -version

# Případně nainstalujte:
choco install adoptopenjdk8
```

### Problem: Oprávnění
Spusťte PowerShell/CMD jako administrátor.

## Po instalaci

Jakmile bude SDK nainstalováno, můžete použít naše skripty:

```powershell
# Build a spuštění v emulátoru:
.\build_and_run.ps1

# Nebo v VS Code:
# Ctrl+Shift+P → "Tasks: Run Task" → "Build and Run PeakSleep"
```

## Ověření funkčnosti

```powershell
# Zkontrolujte dostupné příkazy:
monkeyc --help
connectiq --help

# Zkontrolujte dostupná zařízení:
connectiq --list-devices
``` 