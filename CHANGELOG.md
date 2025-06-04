# Changelog - PeakSleep

## [Verze 2.0] - Vylepšení Recharge Rate s historickými daty

### ✨ Nové funkce

#### Historická analýza spánku
- **Automatická analýza** posledních 7 dnů spánku
- **Detekce spánkových období** na základě Body Battery trendů  
- **Výpočet skutečné regenerační rychlosti** z historických dat
- **Inteligentní filtrování** nekvalitních spánků

#### Vylepšený algoritmus recharge rate
- **Kombinace historických a nastavených dat** (70% historická + 30% nastavená rychlost)
- **Vážený průměr** s důrazem na novější data
- **Cache systém** pro optimální výkon
- **Automatické denní aktualizace**

#### Nové API funkce
- `getEnhancedRechargeRate()` - hlavní vylepšená funkce
- `getHistoricalAnalysisStats()` - statistiky pro UI
- `analyzeSleepPatterns()` - analýza spánkových vzorců
- `clearHistoricalData()` - debug funkce

### 🔧 Technické změny

#### SleepLogic.mc
- Přidán import `Toybox.Time.Gregorian`
- Nové konstanty pro historickou analýzu
- Definice `SleepPattern` struktury
- 5 nových funkcí pro historickou analýzu

#### PeakSleepView.mc
- Zjednodušené volání `getEnhancedRechargeRate()`
- Odstranění dupliktního kódu pro výpočet recharge rate

#### Nové soubory
- `HistoricalStatsView.mc` - view pro zobrazení statistik
- `Vylepšení_Recharge_Rate.md` - podrobná dokumentace
- `CHANGELOG.md` - tento changelog

### 🎯 Výhody

#### Pro uživatele
- **Přesnější predikce** času spánku na základě skutečných dat
- **Personalizace** podle individuálních spánkových vzorců
- **Postupné zlepšování** s více historickými daty
- **Robustnost** - fallback na původní systém při nedostatku dat

#### Pro vývojáře
- **Modulární design** - jednoduché rozšíření
- **Optimalizace výkonu** - cache a lazy loading
- **Důkladné logování** pro debug
- **Zpětná kompatibilita** - zachování původní funkcionality

### 🔍 Algoritmus

#### Detekce spánku
1. Analýza Body Battery za posledních 7 dní
2. Identifikace vzestupných trendů (>5 bodů)
3. Filtrování nočních hodin (21:00-06:00)
4. Validace délky spánku (3-12 hodin)

#### Výpočet rychlosti
1. Výpočet recharge rate pro každý spánek: `(endBB - startBB) / duration`
2. Filtrování kvalitních spánků (stres <70, rychlost 3-25 BB/h)
3. Vážený průměr s lineárním poklesem váhy podle stáří
4. Kombinace s nastavenou rychlostí (70% historická + 30% nastavená)

#### Cache a optimalizace
- Historická data se přepočítávají pouze jednou za 24 hodin
- Uložení výsledku do persistent storage
- Rychlý fallback na původní systém při problémech

### 📊 Nové konstanty

```monkey-c
const SLEEP_ANALYSIS_DAYS = 7;               // Počet dnů pro analýzu
const MIN_SLEEP_DURATION_HOURS = 3;          // Minimální doba spánku
const MAX_SLEEP_DURATION_HOURS = 12;         // Maximální doba spánku
const HISTORICAL_RECHARGE_RATE_KEY = "historicalRechargeRate";
const SLEEP_PATTERNS_KEY = "sleepPatterns";
```

### 🚀 Budoucí vylepšení

Připravené možnosti pro další verze:
- Sezónní adaptace
- Korelace s fyzickou aktivitou
- Machine learning algoritmy
- Uživatelská zpětná vazba
- Trend analýza

---

## [Verze 1.0] - Původní implementace

### Základní funkce
- Statický recharge rate z nastavení
- Základní úprava podle stresu (HR vs RHR)
- Výpočet potřebného času spánku
- Doporučení času pro spaní 