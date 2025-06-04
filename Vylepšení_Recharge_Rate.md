# Vylepšení výpočtu Recharge Rate s historickými daty

## Přehled vylepšení

Implementoval jsem pokročilý systém pro výpočet recharge rate, který kombinuje:

1. **Historická analýza spánku** - analýza skutečné regenerace z posledního týdne
2. **Uživatelské nastavení** - základní rychlost nastavená uživatelem  
3. **Aktuální stresový stav** - úprava podle srdeční frekvence

## Klíčové funkce

### 1. Analýza historických dat (`analyzeSleepPatterns()`)

```monkey-c
function analyzeSleepPatterns() as Array<SleepPattern>?
```

**Co dělá:**
- Získává Body Battery data za posledních 7 dní
- Detekuje periody spánku na základě vzestupných trendů BB
- Analyzuje každou periodu spánku a počítá skutečnou rychlost regenerace
- Filtruje pouze kvalitní spánky (bez vysokého stresu)

**Detekce spánku:**
- Hledá nárůst BB o více než 5 bodů
- Pouze v nočních hodinách (21:00 - 06:00)
- Minimální doba spánku: 3 hodiny
- Maximální doba spánku: 12 hodin

### 2. Výpočet historické rychlosti (`calculateHistoricalRechargeRate()`)

```monkey-c
function calculateHistoricalRechargeRate(patterns as Array<SleepPattern>?) as Float?
```

**Algoritmus:**
- Filtruje pouze kvalitní spánky (stres < 70, rychlost 3-25 BB/h)
- Počítá vážený průměr s důrazem na novější data
- Novější data mají vyšší váhu podle lineárního poklesu
- Cachuje výsledek pro rychlejší přístup

### 3. Vylepšený výpočet (`getEnhancedRechargeRate()`)

```monkey-c
function getEnhancedRechargeRate() as Float
```

**Postup:**
1. **Cache check** - zkontroluje uloženou historickou rychlost
2. **Denní update** - přepočítá historickou rychlost jednou denně
3. **Kombinace dat** - váženě kombinuje historickou (70%) a nastavenou (30%) rychlost
4. **Stresová úprava** - aplikuje aktuální úpravu podle HR/RHR

## Struktura dat

### SleepPattern

```monkey-c
typedef SleepPattern as {
    "startBB" as Number,         // Body Battery na začátku spánku
    "endBB" as Number,           // Body Battery na konci spánku  
    "duration" as Float,         // Doba spánku v hodinách
    "rechargeRate" as Float,     // Vypočítaná rychlost regenerace
    "avgStress" as Float,        // Průměrný stres během spánku
    "timestamp" as Number        // Timestamp spánku
};
```

## Výhody oproti původnímu systému

### 1. **Personalizace**
- Učí se z vašeho skutečného spánku
- Přizpůsobuje se individuálním vzorcům
- Zohledňuje věk, kondici, zdravotní stav

### 2. **Přesnost**
- Používá skutečná data místo obecných odhadů
- Průběžně se zlepšuje s více daty
- Filtruje nekvalitní spánky

### 3. **Adaptivnost**
- Reaguje na změny ve spánkovém režimu
- Dává větší váhu novějším datům
- Kombinuje historická data s aktuálním stavem

### 4. **Fallback mechanismus**
- Pokud historická data nejsou dostupná, používá původní systém
- Postupné přechod na historická data s více informacemi
- Robustní proti chybám v datech

## Implementační detaily

### Konstanty

```monkey-c
const SLEEP_ANALYSIS_DAYS = 7;               // Počet dnů pro analýzu
const MIN_SLEEP_DURATION_HOURS = 3;          // Minimální doba spánku
const MAX_SLEEP_DURATION_HOURS = 12;         // Maximální doba spánku
const HISTORICAL_RECHARGE_RATE_KEY = "historicalRechargeRate";
```

### Cache systém

- **Klíč:** `historicalRechargeRate` - uložená historická rychlost
- **Klíč:** `lastHistoricalUpdate` - timestamp posledního update
- **Interval:** 24 hodin mezi přepočty

### Váhový systém

```monkey-c
// Lineární pokles váhy podle stáří dat
var weight = ageInDays < 7 ? (7.0f - ageInDays) / 7.0f : 0.1f;
```

- Data mladší než 1 den: váha 100%
- Data starší než 7 dní: váha 10%
- Lineární pokles mezi těmito body

## Integrace do aplikace

### Změny v PeakSleepView.mc

```monkey-c
// Původní kód:
var baseRechargeRate = SleepLogic.getBaseRechargeRate(); 
var adjustedRechargeRate = SleepLogic.calculateAdjustedRechargeRate(baseRechargeRate, avgHR, restingHR);

// Nový kód:
var adjustedRechargeRate = SleepLogic.getEnhancedRechargeRate();
```

### Nové API funkce

- `SleepLogic.getEnhancedRechargeRate()` - hlavní funkce
- `SleepLogic.getHistoricalAnalysisStats()` - statistiky pro UI
- `SleepLogic.clearHistoricalData()` - vymazání cache (debug)

## Výkonnost

### Optimalizace

1. **Cache systém** - historická data se přepočítávají pouze jednou denně
2. **Lazy loading** - analýza pouze při první potřebě
3. **Filtrování** - zpracovává pouze relevantní data
4. **Fallback** - rychlé přepnutí na původní systém při problémech

### Paměťová náročnost

- Ukládá pouze agregované výsledky, ne raw data
- Minimální persistent storage (~50 bytů)
- Dočasná data během analýzy (~2-5 KB)

## Testování

### Debug funkce

```monkey-c
// Vymazání historických dat pro testování
SleepLogic.clearHistoricalData();

// Zobrazení statistik
var stats = SleepLogic.getHistoricalAnalysisStats();
```

### Kontrolní mechanismy

- Logování všech klíčových kroků
- Validace vstupních dat
- Fallback na původní systém při chybách
- Sanity check výsledků (3-25 BB/h)

## Budoucí vylepšení

### Možná rozšíření

1. **Seasonal adaptation** - zohlednění ročních období
2. **Activity correlation** - vazba na fyzickou aktivitu
3. **Sleep quality metrics** - integrace s dalšími sleep sensory
4. **Machine learning** - pokročilejší algoritmy predikce
5. **User feedback** - možnost korekce výsledků uživatelem

### API rozšíření

1. **Trend analysis** - dlouhodobé trendy regenerace
2. **Sleep debt calculation** - kumulativní deficit spánku
3. **Optimal bedtime prediction** - predikce ideálního času spánku
4. **Recovery recommendations** - doporučení pro zlepšení regenerace

## Závěr

Implementované vylepšení poskytuje výrazně přesnější odhady recharge rate díky:

- Využití skutečných historických dat z posledního týdne
- Inteligentní kombinaci různých zdrojů informací
- Adaptivní algoritmy s důrazem na novější data
- Robustní fallback mechanismy

Systém se postupně zlepšuje s více daty a poskytuje personalizované odhady místo obecných konstant. 