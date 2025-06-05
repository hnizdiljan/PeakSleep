# Implementace Enhanced Recharge Rate - Návod

## ✅ Co bylo implementováno

### 🔧 Změny v existujících souborech

#### `source/SleepLogic.mc`
- ✅ Přidán import `Toybox.Time.Gregorian`
- ✅ Definovány konstanty pro historickou analýzu
- ✅ Přidána struktura `SleepPattern`
- ✅ Implementováno **5 nových funkcí**:
  - `analyzeSleepPatterns()` - analýza 7 dní historie
  - `detectSleepPeriods()` - detekce spánkových období
  - `analyzeSingleSleepPeriod()` - analýza jednotlivého spánku
  - `calculateHistoricalRechargeRate()` - výpočet z historie
  - `getEnhancedRechargeRate()` - **hlavní vylepšená funkce**
  - `getHistoricalAnalysisStats()` - statistiky pro UI
  - `clearHistoricalData()` - debug funkce

#### `source/PeakSleepView.mc`  
- ✅ Nahrazeno volání `getBaseRechargeRate()` + `calculateAdjustedRechargeRate()` 
- ✅ Nyní používá jedinou funkci: `getEnhancedRechargeRate()`

#### `source/PeakSleepDelegate.mc`
- ✅ Přidána navigace na HistoricalStatsView pomocí swipe DOWN/LEFT

### 🆕 Nové soubory

#### `source/HistoricalStatsView.mc`
- ✅ Nový view pro zobrazení statistik historické analýzy
- ✅ Ukazuje porovnání historické vs nastavené rychlosti
- ✅ Indikace stáří dat a dostupnosti historie

#### `source/HistoricalStatsDelegate.mc`  
- ✅ Delegate pro obsluhu HistoricalStatsView
- ✅ Back/Menu pro návrat, Select pro vymazání dat (testing)

#### Dokumentace
- ✅ `Vylepšení_Recharge_Rate.md` - podrobná technická dokumentace
- ✅ `CHANGELOG.md` - přehled změn a nových funkcí

## 🚀 Jak začít používat

### 1. Build a nasazení
```bash
# V Connect IQ SDK
monkeyc -f monkey.jungle -o PeakSleep.prg
```

### 2. Testování implementace

#### První spuštění
1. **Spusť aplikaci** - bude používat původní algoritmus (fallback)
2. **Zkontroluj logs** - měly by zobrazit `"Using base rate only"`
3. **Otestuj navigaci** - swipe DOWN pro přechod na Historical Stats

#### Testování s daty
1. **Vymaž cache** - dlouhé stisknutí SELECT v Historical Stats view
2. **Nech aplikaci běžet** týden pro sběr dat
3. **Sleduj postupné zlepšování** přesnosti

### 3. Navigace v aplikaci

```
[Hlavní view - PeakSleepView]
       ↑ UP → Bedtime Advisor
       ↓ DOWN → Historical Stats  ← NOVÉ!
       → RIGHT → Bedtime Advisor
       ← LEFT → Historical Stats   ← NOVÉ!
```

## 🔍 Debugging a testování

### Debug výstupy v logu

```
SleepLogic: Getting enhanced recharge rate
SleepLogic: Recalculating historical recharge rate  
SleepLogic: Analyzing historical sleep patterns
SleepLogic: Found X Body Battery samples
SleepLogic: Analyzed Y sleep patterns
SleepLogic: Historical recharge rate: Z.XX
```

### Testovací funkce

V `test_enhanced_recharge.mc` jsou připravené testovací funkce:
```monkey-c
// Pro rychlé testování volej z onUpdate():
runAllTests();
```

### Manuální testování

1. **Vymaž historická data:**
   ```monkey-c
   SleepLogic.clearHistoricalData();
   ```

2. **Zkontroluj statistiky:**
   ```monkey-c
   var stats = SleepLogic.getHistoricalAnalysisStats();
   ```

3. **Vynuť přepočet:**
   ```monkey-c
   // Smaž lastHistoricalUpdate timestamp
   Application.Storage.deleteValue("lastHistoricalUpdate");
   ```

## 📊 Očekávané chování

### První týden používání
- **Den 1-3:** Používá pouze nastavený rate (fallback)
- **Den 4-7:** Začíná kombinovat historická data (pokud dostupná)
- **Týden 2+:** Plně personalizované odhady

### Indikátory v Historical Stats view
- 🟢 **Zelená:** Historická data dostupná a čerstvá
- 🟡 **Žlutá:** Data dostupná ale starší než 3 dny  
- 🔴 **Červená:** Data starší než týden
- ⚠️ **Žlutá:** Shromažďuje data (žádná historie)

## ⚙️ Konfigurace

### Dostupné konstanty (SleepLogic.mc)
```monkey-c
const SLEEP_ANALYSIS_DAYS = 7;               // Dní k analýze
const MIN_SLEEP_DURATION_HOURS = 3;          // Min doba spánku  
const MAX_SLEEP_DURATION_HOURS = 12;         // Max doba spánku
```

### Storage klíče
```monkey-c
"historicalRechargeRate"    // Cached historická rychlost
"lastHistoricalUpdate"      // Timestamp posledního přepočtu
"sleepPatterns"             // (nepoužito - pro budoucí rozšíření)
```

## 🔧 Řešení problémů

### Problém: "No historical data"
**Řešení:** 
- Zkontroluj, že zařízení podporuje `SensorHistory.getBodyBatteryHistory()`
- Nech aplikaci běžet několik dní pro sběr dat
- Zkontroluj, že spíš v nočních hodinách (21:00-06:00)

### Problém: "Using base rate only"  
**Řešení:**
- Normální při prvním spuštění
- Historická data se vytváří postupně
- Po týdnu by se mělo zobrazit "Combined rate"

### Problém: Compilation errors
**Řešení:**
- Zkontroluj, že `manifest.xml` obsahuje permission `SensorHistory`
- Ověř, že všechny importy jsou správné
- Zkontroluj minimum API level (3.1.0+)

## 📈 Budoucí vylepšení

Připravené možnosti pro rozšíření:
- [ ] Sezónní adaptace (winter/summer patterns)
- [ ] Korelace s fyzickou aktivitou  
- [ ] Machine learning algoritmy
- [ ] User feedback integration
- [ ] Weekly/monthly trend analysis

## 🎯 Klíčové metriky úspěchu

Po týdnu používání očekávej:
- **Přesnější predikce** času spánku (±15-30 min)
- **Personalizace** podle tvých vzorců  
- **Postupné zlepšování** s více daty
- **Robustnost** - fallback vždy funguje

---

**📝 Poznámka:** Test soubor `test_enhanced_recharge.mc` není součástí finální aplikace - můžeš ho smazat před releasem. 