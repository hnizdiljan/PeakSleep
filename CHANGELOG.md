# Changelog - PeakSleep

## [Verze 2.3] - Zjednodušení aplikace (2024-12-15)

### 🗑️ Odstraněno
- **Daily Stats obrazovka** - kvůli známému Garmin SDK bug
  - Funkce `getBodyBatteryHistory()` způsobuje Out of Memory chyby na Fenix 6S Pro a dalších zařízeních
  - Zdroj: https://forums.garmin.com/developer/connect-iq/i/bug-reports/out-of-memory-when-calling-getbodybatteryhistory-2014086388
  - Odstraněny soubory: `DailyStatsView.mc`, `DailyStatsDelegate.mc`, dokumentace

- **Historical Stats obrazovka** - kvůli zjednodušení aplikace
  - Odstraněny soubory: `HistoricalStatsView.mc`, `HistoricalStatsDelegate.mc`
  - Odstraněna dokumentace: `Vylepšení_Recharge_Rate.md`
  - Odstraněny všechny Enhanced Recharge Rate funkce ze `SleepLogic.mc`

### 🔧 Změny navigace
- Vrácena navigace na 2 základní obrazovky:
  - **Hlavní obrazovka** ↔ **Bedtime Advisor**
  - Swipe UP z hlavní obrazovky → Bedtime Advisor
  - Swipe DOWN z hlavní obrazovky → Bedtime Advisor
  - Všechny swipe gesta z Bedtime Advisor → návrat na hlavní obrazovku

### 🛡️ Vylepšení stability
- Aplikace používá pouze základní recharge rate z nastavení
- Odstranění všech problematických Garmin API funkcí
- Jednoduchá a stabilní implementace bez složitých algoritmů
- Vrácení k původní logice z verze 1.0

---

## [Verze 2.2] - Daily Sleep Statistics (2024-12-04) - ODSTRANĚNO v 2.3

### 🆕 Hlavní novinky

#### Třetí obrazovka - Denní Statistiky
- **Nový view** pro detailní přehled posledních 7 dnů
- **Pokročilá detekce spánku** místo simple min/max algoritmu
- **Personalizované hodnocení kvality** spánku (Výborná/Dobrá/Slabá)
- **Scrollovatelný seznam** s intuitivní navigací

#### Vylepšený algoritmus detekce spánku
- **Detekce aktivity před spánkem** - pokles BB ≥5 bodů v nočních hodinách
- **Identifikace regeneračního období** - nárůst BB ≥8 bodů v ranních hodinách
- **Fallback mechanismus** na tradiční min/max při selhání
- **Časová omezení** pro rozumné výsledky (3-12h spánku)

#### Nové zobrazené informace
- **Datum spánku** - "Dnes", "Včera" nebo "15.1"
- **Čas usnutí/probuzení** - "23:30 - 07:15"
- **Doba spánku** - "7.8h"
- **Rychlost regenerace** - "9.2 BB/h"
- **Body Battery rozsah** - "45 → 78 BB"
- **Kvalita spánku** - barevně rozlišená

### 📱 Navigace
- **Swipe RIGHT** z hlavní obrazovky → Denní Statistiky
- **Swipe UP/DOWN** → Scrollování v seznamu denních statistik
- **Select** → Refresh dat
- **Back/Menu** → Návrat na hlavní obrazovku

### 🔧 Technické změny

#### Nové soubory
- `source/DailyStatsView.mc` - UI komponenta pro denní statistiky
- `source/DailyStatsDelegate.mc` - Controller pro navigaci a scrollování
- `Denní_Statistiky_Regenerace.md` - podrobná dokumentace

#### SleepLogic.mc rozšíření
- `DailyStat` typedef pro strukturu denních dat
- `collectDailyStats()` - sběr a analýza půlhodinových vzorků
- `detectSleepPeriodAdvanced()` - pokročilá detekce spánkových období
- `serializeDailyStatsToCache()` - optimalizace storage
- Cache systém s 6hodinovým refresh intervalem

#### PeakSleepDelegate.mc
- Nová navigace **Swipe RIGHT** → Daily Stats
- Reorganizace swipe směrů pro lepší UX

### ⚡ Optimalizace
- **Půlhodinové vzorkování** místo minutového (menší paměťová náročnost)
- **Serializace cache** pro kompatibilitu s Application.Storage
- **Lazy loading** dat při prvním zobrazení
- **Smart refresh** - data se aktualizují pouze každých 6 hodin

### 🎯 Kvalita spánku

#### 🟢 Výborná (≥10 BB/h, ≥7h)
- Optimální regenerace
- Zelená barva

#### 🟡 Dobrá (≥7 BB/h, ≥6h)
- Uspokojivá regenerace
- Žlutá barva

#### 🔴 Slabá (pod limity)
- Potřeba zlepšení
- Červená barva

---

## [Verze 2.1] - Memory Optimizations (2024-12-04)

### 🚨 Kritické opravy
- **OPRAVENO**: "Out of Memory Error" při spuštění aplikace
- **OPRAVENO**: Přetečení paměti při historické analýze

### ⚡ Optimalizace výkonu
- Zkrácení doby analýzy ze 7 na 3 dny (snížení paměťové náročnosti)
- Omezení vzorků na 500 místo neomezeného načítání
- Stream processing místo načítání všech dat do paměti najednou
- Prodloužení intervalu UI aktualizací z 5 na 15 sekund
- Cache pro recharge rate - aktualizace každých 60 sekund

### 🛡️ Vylepšení stability
- Try-catch blokování pro kritické funkce
- Error handling pro předcházení pádům aplikace
- Fallback hodnoty při selhání historické analýzy
- Automatické vyčištění paměti po zpracování dat

### 🔧 Technické změny
- `analyzeSleepPatternsOptimized()` - nová optimalizovaná verze
- `analyzeSingleSleepPeriodOptimized()` - bez náročných API volání
- Zjednodušený výpočet stresu (průměrná hodnota místo API)
- Méně časté přepočítávání (každé 2 dny místo denně)

---

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