# Connect IQ Store listing – Peak Sleep 3.1.0

Store page: https://apps.garmin.com/apps/959a7cf1-fcbf-43fa-970b-93e469f4e4f8
Package: `publish/PeakSleep-3.1.0.iq` (signed with `developer_key`, same key as 1.x)
Version to enter on upload: **3.1.0** (store has 3.0.0, released 2026-10-22)

Texts below are plain text – the store does not render Markdown (copy everything between the lines).

## Images

| File | Use |
|---|---|
| `icon.jpg` (500×500, unchanged) | Store icon |
| `store/hero-1440x720.jpg` | Hero image (optional, mobile store) |
| `store/screenshots/en-1-glance.png` | Screenshot 1 – glance list row |
| `store/screenshots/en-2-answer.png` | Screenshot 2 – answer page |
| `store/screenshots/en-3-why.png` | Screenshot 3 – why page |
| `store/screenshots/en-4-last-nights.png` | Screenshot 4 – last nights |
| `store/screenshots/en-5-sleep-now.png` | Screenshot 5 – go to sleep now |
| `store/screenshots/en-6-morning.png` | Screenshot 6 – morning summary (answer page, new in 3.1.0) |
| `store/screenshots/en-7-morning-glance.png` | Screenshot 7 – morning summary in the glance (new in 3.1.0) |
| `store/screenshots/cs-1-glance.png`, `cs-2-answer.png` | Czech alternatives (for a Czech listing, if used) |

The store allows at most 5 screenshots; 3.1.0 uses en-1 to en-4 and en-6 (en-5 and en-7 are spares).
All screenshots are 500×500 PNG under 150 KB, rendered from the real app on fēnix 8 43mm.

---

## Description (EN)

----------------------------------------------------------------
Peak Sleep: when should I go to bed to wake up with 100% Body Battery?

Peak Sleep answers one question right in your glance list:
"Sleep at 22:40 – in 1 h 20 min · BB 54%"

It learns how fast YOUR Body Battery recharges at night and how fast it drains in the evening, and calculates the latest bedtime that still gets you to your target by your alarm.

WHAT YOU SEE
- Glance: bedtime and countdown. Yellow = plan, blue = go to sleep now, red = target out of reach (shows how much you will still get), green = already above target.
- Answer: Body Battery ring (the darker part is what the evening will still drain), bedtime, countdown, Body Battery at bedtime.
- Why: the inputs – Body Battery now, evening drain, recharge rate and where it comes from.
- Last nights: recharge rate of up to 7 learned nights.
- Morning summary (after waking up until noon): "Charged to 92%", whether you went to bed on time ("35 min late") and how many nights in a row you fell short of your target or reached it.

HOW IT WORKS
- A background service stores one Body Battery sample every 30 minutes.
- From these samples the widget finds each night (fall asleep = lowest point, wake up = highest point) and learns your recharge rate and evening drain (median of the last 7 nights).
- Learning needs 3 valid nights. Until then it uses the manual rate (default 10 BB/h) and shows "learning N/3".
- The alarm time comes from your Garmin sleep schedule, or you can set it manually.

SETTINGS (Garmin Connect app or on the watch via Menu)
- Target Body Battery: 50–100% (default 100)
- Recharge rate: Auto (learned) or Manual (1–30 BB/h)
- Alarm source: Garmin sleep schedule or Manual (hour / minute)
- Reset learned data (on the watch)

TIPS
- Open the widget at least every other day so no night is missed.
- Nights with a gap in data longer than 2 hours (watch off or charging) are skipped.

Languages: English, Czech.
Requires a watch with Body Battery. Forerunner 645 / 645 Music / 935 are no longer supported (no Body Battery API).
----------------------------------------------------------------

## What's New – 3.1.0 (EN)

----------------------------------------------------------------
Peak Sleep 3.1 – morning summary

NEW
- Morning summary in the glance and on the main page: after you wake up it shows how much Body Battery you reached ("Charged to 92%"), whether you went to bed on time ("35 min late") and your streak ("3 nights short" / "5 good nights"). It stays until noon.
- Wake-up detection: the night is closed when Body Battery stops rising and you have walked at least 100 steps.

FIXED
- Last night is learned right after you wake up. Before, it took until about 3 hours after your usual wake time, so in the morning the Last nights page still said "No nights yet".
----------------------------------------------------------------

## What's New – 3.0.0 (EN)

----------------------------------------------------------------
Peak Sleep 3.0 – completely redesigned

NEW
- Glance in the widget list: "Sleep at 22:40 · in 1 h 20 min · BB 54%".
- Automatic recharge rate learned from your own nights (median of the last 7, active after 3 nights).
- Evening drain prediction – the bedtime now accounts for Body Battery you will still lose before sleep.
- If the target is out of reach, it shows how much you will reach by your alarm.
- Adjustable target (50–100%) and alarm from your Garmin sleep schedule.
- New pages: Answer (Body Battery ring), Why (inputs of the calculation), Last nights (chart).
- Settings directly on the watch (Menu), including reset of learned data.
- Czech language.

IMPROVED
- Much more reliable: only the latest Body Battery value is read, which fixes out-of-memory crashes on older watches.
- Texts fit on every supported screen.

REMOVED
- Heart-rate based adjustment and HR/RHR display.
- Forerunner 645 / 645 Music / 935 (their firmware has no Body Battery API).

PERMISSIONS
- New "Background" permission: needed to sample Body Battery every 30 minutes for learning.
- Heart-rate sensor access is no longer used.
----------------------------------------------------------------

---

## Popis (CS) – pro českou verzi stránky, pokud ji ve storu přidáš

----------------------------------------------------------------
Peak Sleep: v kolik jít spát, abych se ráno probudil se 100 % Body Battery?

Peak Sleep odpoví přímo v seznamu widgetů:
„Spát ve 22:40 – za 1 h 20 min · BB 54 %“

Naučí se, jak rychle se TVOJE Body Battery v noci nabíjí a jak rychle se večer vybíjí, a spočítá nejpozdější čas usnutí, se kterým se do budíku dobiješ na cíl.

CO UVIDÍŠ
- Glance: čas usnutí a odpočet. Žlutá = plán, modrá = jdi spát teď, červená = cíl nestihneš (ukáže, kolik dobiješ), zelená = už jsi nad cílem.
- Odpověď: prstenec Body Battery (tmavší část je to, co ještě večer vybiješ), čas usnutí, odpočet, BB při usnutí.
- Proč: vstupy výpočtu – BB teď, večerní vybíjení, rychlost nabíjení a její zdroj.
- Poslední noci: rychlost nabíjení až za 7 naučených nocí.
- Ranní souhrn (po probuzení do poledne): „Nabito na 92 %“, jestli bylo usnutí včas („pozdě o 35 min“) a kolik nocí po sobě jsi cíl nestihl nebo splnil.

JAK TO FUNGUJE
- Služba na pozadí každých 30 minut uloží jednu hodnotu Body Battery.
- Z nich widget najde každou noc (usnutí = nejnižší bod, probuzení = nejvyšší) a naučí se rychlost nabíjení a večerního vybíjení (medián posledních 7 nocí).
- Učení potřebuje 3 platné noci. Do té doby používá ruční rychlost (výchozí 10 BB/h) a ukazuje „učím se N/3“.
- Čas budíku bere z plánu spánku Garmin, nebo si ho nastavíš ručně.

NASTAVENÍ (aplikace Garmin Connect nebo v hodinkách přes Menu)
- Cílová Body Battery: 50–100 % (výchozí 100)
- Rychlost nabíjení: Auto (naučená) nebo Ruční (1–30 BB/h)
- Zdroj budíku: plán spánku Garmin nebo ruční (hodina / minuta)
- Smazat naučená data (v hodinkách)

TIPY
- Otevři widget aspoň jednou za 2 dny, ať se žádná noc neztratí.
- Noc s mezerou v datech delší než 2 hodiny (vypnuté nebo nabíjené hodinky) se nezapočítá.

Jazyky: angličtina, čeština.
Vyžaduje hodinky s Body Battery. Forerunner 645 / 645 Music / 935 už podporované nejsou (nemají API pro Body Battery).
----------------------------------------------------------------

## Co je nového – 3.1.0 (CS)

----------------------------------------------------------------
Peak Sleep 3.1 – ranní souhrn

NOVÉ
- Ranní souhrn v glance a na hlavní stránce: po probuzení ukáže, na kolik % ses dobil („Nabito na 92 %“), jestli bylo usnutí včas („pozdě o 35 min“) a sérii nocí („3 noci pod cílem“ / „5 nocí na cíli“). Zůstane do poledne.
- Rozpoznání probuzení: noc se uzavře, když Body Battery přestane růst a ujdeš aspoň 100 kroků.

OPRAVENO
- Poslední noc se naučí hned po probuzení. Dřív to trvalo až zhruba 3 hodiny po obvyklém čase buzení, takže ráno stránka Poslední noci ukazovala „Zatím žádné noci“.
----------------------------------------------------------------

## Co je nového – 3.0.0 (CS)

----------------------------------------------------------------
Peak Sleep 3.0 – kompletně přepracovaný

NOVÉ
- Glance v seznamu widgetů: „Spát ve 22:40 · za 1 h 20 min · BB 54 %“.
- Automatická rychlost nabíjení naučená z tvých nocí (medián posledních 7, aktivní po 3 nocích).
- Predikce večerního vybíjení – čas usnutí počítá s tím, kolik BB ještě do spánku ubude.
- Když cíl nestihneš, ukáže, kolik do budíku dobiješ.
- Nastavitelný cíl (50–100 %) a budík z plánu spánku Garmin.
- Nové stránky: Odpověď (prstenec BB), Proč (vstupy výpočtu), Poslední noci (graf).
- Nastavení přímo v hodinkách (Menu) včetně smazání naučených dat.
- Čeština.

VYLEPŠENO
- Výrazně spolehlivější: čte se jen poslední hodnota Body Battery, což opravuje pády kvůli paměti na starších hodinkách.
- Texty se vejdou na všechny podporované displeje.

ODEBRÁNO
- Úprava podle tepu a zobrazení HR/RHR.
- Forerunner 645 / 645 Music / 935 (firmware nemá API pro Body Battery).

OPRÁVNĚNÍ
- Nové oprávnění „Background“: sběr Body Battery každých 30 minut pro učení.
- Senzor tepu se už nepoužívá.
----------------------------------------------------------------
