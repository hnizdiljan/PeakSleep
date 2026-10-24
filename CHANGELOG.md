# Changelog - PeakSleep

## [Verze 3.2.0] - Další jazyky (2026-10-24)

### Nové
- **7 nových jazyků**: španělština, němčina, francouzština, italština, portugalština, nizozemština
  a polština (kromě angličtiny a češtiny). Jazyk se řídí nastavením hodinek, nastavení v Garmin
  Connect jazykem telefonu.

## [Verze 3.1.0] - Ranní souhrn (2026-10-23)

### Nové
- **Ranní souhrn** v glance a na hlavní stránce: po probuzení ukáže, na kolik % ses dobil
  („Nabito na 92 %“), jestli jsi usnul včas („pozdě o 35 min“) a sérii nocí pod cílem / na cíli
  („3 noci pod cílem“). Zobrazuje se do poledne (nejméně 2 h po probuzení).
- **Rozpoznání probuzení**: noc je uzavřená, když Body Battery přestane růst a od půlnoci přibude
  aspoň 100 kroků.

### Opraveno
- Poslední noc se naučila až 3 hodiny po obvyklém probuzení, takže ráno stránka Poslední noci
  ukazovala „Zatím žádné noci“. Teď se noc vyhodnotí hned (ze vzorků do teď) a při dalším otevření
  widgetu se zpřesní.

## [Verze 3.0] - Redesign: glance, učení z nocí, nové UX (2026-10-22)

### Nové
- **Glance** v seznamu widgetů: „☾ Spát ve 22:40 · za 1 h 20 min · BB 54 %“ se 6 stavy
  (plán / jdi spát teď / nestihneš / nad cílem / učí se / chybí data).
- **Automatická rychlost nabíjení** naučená z posledních 7 nocí (medián, od 3 platných nocí).
- **Predikce večerního vybíjení** – doporučený čas počítá s tím, kolik BB do usnutí ještě ubude.
- Když cíl nestihneš, ukáže **kolik % do budíku dobiješ**.
- **Nastavitelný cíl** (50–100 %) a **budík z plánu spánku Garmin**.
- Nové stránky: **Odpověď** (prstenec BB), **Proč** (vstupy výpočtu), **Poslední noci** (graf).
- **Nastavení přímo v hodinkách** (Menu), včetně smazání naučených dat.
- **Čeština**.

### Změněno
- Background služba každých 30 min ukládá jeden vzorek BB; dlouhá historie se nikdy nečte (OOM).
- Odstraněna úprava rychlosti podle tepu a zobrazení HR/RHR.
- Sjednocená výchozí ruční rychlost na 10 BB/h.
- Kód rozdělen na `core` (čistá logika s unit testy), `data` a `ui`; odstraněny debug výpisy.
- Migrace: uživatelé s vlastním budíkem (≠ 7:00) zůstávají na ručním budíku.

### Odebráno
- Podpora Forerunner 645 / 645 Music / 935 (nemají API pro Body Battery).
- Oprávnění `Sensor` (tep se už nečte); přidáno `Background`.

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