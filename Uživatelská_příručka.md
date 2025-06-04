# Peak Sleep - Uživatelská příručka

## Přehled
Peak Sleep je widget pro Garmin Connect IQ, který vám pomáhá určit, kolik spánku potřebujete k úplnému dobití Body Battery. Aplikace využívá váš aktuální stav Body Battery, srdeční frekvenci a klidovou srdeční frekvenci k odhadnutí množství spánku potřebného k dosažení 100% Body Battery. Také poskytuje Poradce pro usínání, který vám pomůže najít ideální čas k usnutí na základě vašeho požadovaného času probuzení a fyziologického stavu.

## Hlavní funkce

### ✅ Zobrazení aktuálních metrik
- **Body Battery**: Aktuální úroveň vaší energie (0-100%)
- **Srdeční frekvence**: Průměrná srdeční frekvence za poslední 2 hodiny
- **Klidová srdeční frekvence**: Nejnižší hodnota za posledních 24 hodin
- **Rychlost dobíjení**: Nastavitelná rychlost nabíjení Body Battery

### ✅ Personalizované výpočty
- Zohledňuje vaši klidovou srdeční frekvenci (RHR) a aktuální srdeční frekvenci
- Upravuje rychlost dobíjení na základě stresu (zvýšená srdeční frekvence)
- Počítá s vašimi individuálními parametry

### ✅ Odhad potřebného spánku
- Zobrazuje, kolik hodin a minut spánku potřebujete k úplnému dobití
- Barevné rozlišení pro rychlé rozpoznání stavu:
  - 🟢 **Zelená**: Body Battery 80-100% (výborný stav)
  - 🟡 **Žlutá**: Body Battery 40-79% (dobrý stav) 
  - 🔴 **Červená**: Body Battery 0-39% (vyčerpání)

### ✅ Poradce pro čas usnutí
- Navrhuje ideální čas k uložení k spánku
- Počítá zpětně od vašeho nastaveného času buzení
- Zobrazuje odpočet do doporučeného času usnutí

## Obrazovky aplikace

### 1. Hlavní obrazovka (Peak Sleep View)
**Co zobrazuje:**
- Body Battery: `85%` *(zelený text)*
- Heart Rate: `72 bpm` *(barevně podle vztahu k RHR)*
- Resting HR: `58 bpm`
- Recharge Rate: `11.0 pts/h` *(nebo upravená hodnota)*
- Est. Sleep: `2h 30m` *(odhadovaný čas spánku)*
- Wake up: `07:30` *(čas probuzení, pokud půjdete spát teď)*

**Barevné rozlišení:**
- **Body Battery**: Zelená (80%+), žlutá (40-79%), červená (0-39%)
- **Srdeční frekvence**: Zelená (blízko RHR), žlutá (mírně zvýšená), červená (výrazně zvýšená)

### 2. Poradce usínání (Bedtime Advisor View)
**Co zobrazuje:**
- Alarm: `06:30` *(váš nastavený čas buzení)*
- Required Sleep: `3h 45m` *(potřebný spánek)*
- To Bed: `22:45` *(ideální čas k usnutí)*
- **Hlavní sdělení**:
  - `2h 15m` - za jak dlouho jít spát
  - `Sleep now!` - jděte spát hned
  - `Too late for full recharge!` - je už příliš pozdě

## Použití aplikace

### Základní použití
1. **Otevřete widget** na vašem Garmin zařízení
2. **Prohlédněte si aktuální stav** - Body Battery, srdeční frekvenci a rychlost dobíjení
3. **Zkontrolujte odhad spánku** - kolik hodin potřebujete k úplnému dobití
4. **Plánujte čas usnutí** podle zobrazeného odhadu

### Navigace mezi obrazovkami

#### 🔘 Tlačítka
- **UP nebo DOWN** - přepínání mezi obrazovkami
- **SELECT** - přepínání mezi obrazovkami (alternativa)
- **BACK** - uzavření widgetu
- **MENU** (dlouhé podržení UP) - záložní možnost

#### 👆 Swipe gesta (dotykový displej)
- **Swipe UP ⬆️** - z hlavní obrazovky na Poradce usínání
- **Swipe RIGHT ➡️** - z hlavní obrazovky na Poradce usínání
- **Swipe LEFT ⬅️** - z hlavní obrazovky na Poradce usínání
- **Swipe DOWN ⬇️** - z Poradce usínání zpět na hlavní obrazovku
- **Swipe LEFT ⬅️** - z Poradce usínání zpět na hlavní obrazovku
- **Swipe RIGHT ➡️** - z Poradce usínání zpět na hlavní obrazovku

### Interpretace hodnot

#### Body Battery
- **100%**: Plně dobito - `"Full"`
- **80-99%**: Výborný stav - zelená barva
- **40-79%**: Dobrý stav - žlutá barva  
- **0-39%**: Vyčerpání - červená barva
- **N/A**: Data nejsou k dispozici

#### Srdeční frekvence vs. RHR
- **HR blízko RHR (+0 až +5)**: Relaxovaný stav - zelená
- **HR mírně zvýšená (+6 až +20)**: Mírný stres - žlutá
- **HR výrazně zvýšená (+21 a více)**: Vysoký stres - červená

#### Odhad spánku
- **"Full"**: Body Battery již na 100%
- **"X h Y m"**: Potřebný čas spánku
- **"Cannot recharge"**: Výpočet není možný

## Nastavení aplikace

### Rychlost dobíjení (Recharge Rate)
- **Výchozí hodnota**: 11.0 bodů za hodinu
- **Rozsah**: 1-30 bodů za hodinu
- **Kde nastavit**: Garmin Connect Mobile → Connect IQ Apps → Peak Sleep → Settings
- **Doporučení**: Nechte výchozí hodnotu, nebo upravte na základě vlastních zkušeností

### Čas buzení (Wake-up Time)
- **Výchozí**: 06:30
- **Rozsah hodin**: 0-23 (24hodinový formát)
- **Rozsah minut**: 0-59
- **Kde nastavit**: Connect IQ Apps → Peak Sleep → Settings
- **Účel**: Používá Poradce usínání pro výpočet ideálního času k uložení

## Podporovaná zařízení

### Série Fenix
- Fenix 6 (všechny varianty: standard, Pro, S, X)
- Fenix 7 (všechny varianty: standard, Pro, S, X, Solar)
- Fenix 8 (43mm, 47mm, Solar varianty)

### Série Forerunner
- FR 245, 645, 645 Music, 745
- FR 935, 945, 945 LTE
- FR 955, 965

### Další zařízení
- Venu, Venu 2 *(dotykový displej)*
- Vivoactive 4, 4S, 5, 6 *(dotykový displej)*

**Požadavky:**
- Connect IQ 3.1.0 nebo vyšší
- Funkce Body Battery
- Senzor srdeční frekvence

**Dotykové funkce:**
- Na zařízeních s dotykovým displejem (Venu, Vivoactive) můžete používat swipe gesta pro přepínání mezi obrazovkami

## Oprávnění aplikace

Aplikace vyžaduje následující oprávnění:
- **Sensor**: Přístup k aktuálním datům srdeční frekvence
- **SensorHistory**: Přístup k historickým datům srdeční frekvence a Body Battery
- **UserProfile**: Přístup ke klidové srdeční frekvenci a záložním hodnotám Body Battery

## Tipy pro efektivní použití

### 📱 Před spaním
- Zkontrolujte widget 30-60 minut před plánovaným usnutím
- Porovnejte odhad s vaším obvyklým časem spánku
- Využijte Poradce usínání k naplánování ideálního času

### 🌙 Optimalizace spánku
- **Vysoká srdeční frekvence** (červená) = delší doba dobíjení
- **Relaxovaný stav** (zelená) = rychlejší dobíjení
- **Stres před spaním** prodlužuje potřebný čas odpočinku

### ⚙️ Přizpůsobení nastavení
- Upravte rychlost dobíjení, pokud si všimnete konstantních odchylek
- Nastavte reálný čas buzení pro přesné doporučení Poradce usínání
- Sledujte trendy několik týdnů pro optimální kalibraci

### 📊 Interpretace výsledků
- **"Too late for full recharge!"** = Jeďte spát ihned nebo upravte očekávání
- **Krátký odhad (< 6h)** = Možná nepotřebujete tolik spánku
- **Dlouhý odhad (> 10h)** = Vysoký stres nebo únava

## Řešení problémů

### ❌ Zobrazuje se "N/A"
**Příčina**: Nedostupná data Body Battery nebo srdeční frekvence
**Řešení**: 
- Počkejte několik minut na získání dat
- Zkontrolujte, že máte zapnuté sledování Body Battery
- Restartujte hodinky

### ❌ Nereálné odhady
**Příčina**: Nesprávná rychlost dobíjení nebo chybné senzory
**Řešení**:
- Upravte rychlost dobíjení v nastavení
- Zkontrolujte správné nasazení hodinek
- Zkalibrujte senzor srdeční frekvence

### ❌ Aplikace neodpovídá
**Řešení**:
- Zavřete a znovu otevřete widget
- Restartujte hodinky
- Přeinstalujte aplikaci z Connect IQ Store

## Požadavky na systém
- **Connect IQ**: verze 3.1.0+
- **Paměť**: minimálně 50 KB volného místa
- **Jazyk**: angličtina (rozhraní)
- **Aktualizace**: automatické přes Garmin Connect

---

*Aplikace je navržena jako pomocný nástroj. Vždy poslouchejte své tělo a konzultujte zdravotní problémy s odborníkem.* 