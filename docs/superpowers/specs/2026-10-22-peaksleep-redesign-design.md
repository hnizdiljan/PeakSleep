# PeakSleep 3.0 – redesign (design dokument)

Datum: 2026-10-22 · Autor: Jan Hnízdil (+ Claude)

## 1. Záměr a proč

PeakSleep je Connect IQ widget, který má odpovědět na **jednu otázku: „V kolik mám jít spát, abych se do budíku dobil na 100 % Body Battery?“**

Současná verze (2.3) na to odpovídá nepřesně a nepřehledně:

- počítá s **aktuálním** BB, jako by uživatel šel spát hned → večer ignoruje, že BB do usnutí ještě klesne, doporučený čas je příliš optimistický,
- rychlost nabíjení (Recharge Rate) si uživatel musí **odhadnout a nastavit ručně**,
- „stresová“ úprava rychlosti porovnává průměrný tep za 2 h (přes den vždy vyšší) s minimem tepu ze spánku → večer rychlost skoro vždy zbytečně snižuje,
- hlavní obrazovka je seznam 6 čísel, odpověď je až na druhé obrazovce,
- všechna tlačítka a gesta dělají totéž, chybí glance, texty jen anglicky, v kódu je hodně debug výpisů a mrtvého kódu.

Cílem 3.0 je: **odpověď na první pohled (glance), výpočet, kterému lze věřit (učí se z vlastních nocí), a intuitivní UX.**

## 2. Cíle

1. **Glance** v seznamu widgetů: „☾ Spát ve 22:40“ + „za 1 h 20 min · BB 54 %“ (varianta A z mockupů).
2. **Automatická rychlost nabíjení** naučená z posledních nocí uživatele; ruční hodnota jen jako výchozí / přepsání.
3. **Predikce večerního vybíjení** – výpočet zohlední, kolik BB uživatel ztratí mezi „teď“ a usnutím.
4. **Hlavní obrazovka s odpovědí** – prstenec BB po obvodu, uprostřed čas usnutí (varianta „1 · Prstenec“).
5. **Srozumitelná navigace na 3 stránky**: Odpověď → Detail výpočtu → Historie nocí.
6. Když už plného dobití nelze dosáhnout, ukázat **kolik % do budíku dobije**.
7. **Nastavitelný cíl** (výchozí 100 %).
8. **Čas budíku** primárně z Garmin profilu (plán spánku), ruční nastavení jako fallback/přepsání.
9. **Lokalizace čeština + angličtina.**
10. **Čistý refaktoring kódu**: oddělená logika výpočtu (testovatelná), datová vrstva, úložiště učení, views; bez debug spamu a mrtvého kódu; unit testy výpočtu.

## 3. Ne-cíle (teď ne, možná později)

- Integrace **Garmin Connect API** (vyžaduje vlastní backend, OAuth, hosting; viz §10).
- **Komplikace** pro ciferník (CIQ 4.2+).
- **Připomínka/notifikace** „jdi spát“.
- Nelineární model nabíjení (pomalejší nabíjení nad ~80 %). Model zůstává lineární.
- Rozšíření seznamu podporovaných zařízení. Ze současných 32 produktů se naopak **odeberou `fr645`, `fr645m`, `fr935`** – mají CIQ < 3.3, a tedy žádné API pro Body Battery (`SensorHistory.getBodyBatteryHistory` vyžaduje API 3.3.0; `UserProfile.getBodyBattery*` v API neexistuje), widget na nich nikdy nemůže fungovat. Zůstává 29 produktů.

## 4. Anti-cíle (selhání, i kdyby to technicky fungovalo)

- Glance nebo widget **spadne na nedostatek paměti** (známý problém `getBodyBatteryHistory()` na Fenix 6S Pro – kvůli němu byla ve 2.3 odstraněna statistika).
- Uživatel nepozná, **jestli hodnotě věřit** (např. auto rychlost z 1 noci tváří se stejně jistě jako ze 7).
- Odpověď je zahrabaná – po otevření widgetu musí být čas usnutí to nejvýraznější na displeji.
- Ořezaný text na kulatých displejích nebo nečitelné prvky na malých (FR245, vivoactive 4S).
- Rozbitá aktualizace pro stávající uživatele (ztráta nastavení rychlosti / budíku).

## 5. UX – co uživatel uvidí

Mockupy: `.superpowers/brainstorm/14347-1792679015/content/glance.html` a `main-view.html`.

### 5.1 Glance (zařízení s podporou glance)

Ikona měsíce (vlastní bitmapa, ne emoji – systémové fonty emoji neumí) + dva řádky. Hlavní je **absolutní čas**, ne odpočet (glance se obnovuje jen občas, odpočet by zastarával).

| Stav | Řádek 1 | Řádek 2 |
|---|---|---|
| Ještě je čas | Spát ve **22:40** (žlutě) | za 1 h 20 min · BB 54 % |
| Je čas jít spát (bedtime ≤ teď, cíl ještě dosažitelný) | **Jdi spát teď** (modře) | 100 % v 6:30 · BB 48 % |
| Nestihne cíl | Spát hned | do budíku jen **85 %** (červeně) |
| BB ≥ cíl (např. přes den po nabití) | **BB 96 %** (zeleně) | dnes spát ~23:10 |
| Učí se (méně než minimum platných nocí) | Spát ve 22:40 | odhad · učím se 2/3 nocí |
| BB nedostupné | PeakSleep | Body Battery nedostupné |

Pozn. ke stavu „BB ≥ cíl“: i při plné baterii se počítá doporučený čas usnutí (vlivem večerního vybíjení může vyjít smysluplný čas). Pokud výpočet dá bedtime až po budíku/nedává smysl, druhý řádek ukáže jen „nabito“.

### 5.2 Hlavní obrazovka (stránka 1 – Odpověď)

- Po obvodu **prstenec BB**: světlý oblouk = aktuální BB, tmavší úsek = predikovaný pokles do usnutí.
- Uprostřed: malý popisek „☾ JDI SPÁT VE“, velký čas **22:40**, pod ním „za 1 h 20 min“.
- Dole: „BB 54 % → 48 % při usnutí“ a „100 % v budík 6:30“ (u stavu „nestihne“: „do budíku jen 85 %“).
- Náznak „⌄“ že existuje další stránka.
- Stejné stavy a barvy jako glance.
- Na zařízeních **bez glance** (po odebrání fr645/fr935 jen `venu`, `vivoactive4`, `vivoactive4s`) je tato stránka zároveň stránkou widgetu ve smyčce widgetů.
- Všechna podporovaná zařízení jsou kulatá – rozložení stačí řešit pro kulaté displeje různých velikostí, relativně k šířce displeje.
- Paměťové limity (ověřeno v `C:\Garmin\Devices`): glance 32 KB na fenix6*, fr245, fr745, fr945(lte); 64 KB na CIQ 5.x; background 32 KB na fenix6*, fr245. Glance kód musí být minimální.

### 5.3 Stránka 2 – Detail výpočtu („Proč 22:40“)

Řádky label / hodnota:
- BB teď – 54 %
- Večer vybiješ – −6 (tempo X/h)
- Nabíjení – 8.6/h + podtitulek „auto · 6 nocí“ / „ruční“ / „odhad · učím se 2/3“
- Cíl – 100 % v 6:30

### 5.4 Stránka 3 – Historie nocí

Sloupcový graf posledních max. 7 naučených nocí (výška = rychlost nabíjení, nebo přírůstek BB; zelená = noc dosáhla cíle, žlutá = ne), pod ním „Ø 8.6 BB/h · Ø délka spánku“. Bez dat: „Zatím žádné noci – vrať se ráno“.

### 5.5 Navigace

**Zařízení s glance** (většina; na CIQ 5.x běží aplikace jako watchApp s glance – typ `widget` tam neexistuje, to je v pořádku):
- Glance → Select/tap otevře stránku 1.
- **Dolů / swipe nahoru** = další stránka; **Nahoru / swipe dolů** = předchozí; na poslední stránce dál nic (nebo cyklicky – rozhodne builder, ale konzistentně).
- **Zpět** = odchod z aplikace (z jakékoli stránky).
- **Menu / dlouhý stisk Up** = nastavení v hodinkách (§7).
- Select na stránce 1 = přechod na stránku 2 (stejné jako Dolů).

**Zařízení bez glance** (`venu`, `vivoactive4`, `vivoactive4s`): stránka 1 je ve smyčce widgetů, kde gesta nahoru/dolů patří systému (přechod na jiný widget). Select/tap otevře stránku 2, odtud nahoru/dolů mezi stránkami 2 a 3, **Zpět** vrátí na stránku 1 ve smyčce. Menu jako výše.

## 6. Výpočet

### 6.1 Vstupy

- `BB` – aktuální Body Battery (stávající pořadí zdrojů ze `SleepLogic.getBodyBattery()` lze zachovat, period 1).
- `G` – cíl v % (nastavení, výchozí 100).
- `A` – čas budíku: nejbližší budoucí výskyt `UserProfile.getProfile().wakeTime`; pokud není k dispozici nebo uživatel zvolil ruční, použije se ruční hodina/minuta z nastavení.
- `r` – rychlost nabíjení (BB/h) z §6.4.
- `d` – tempo večerního vybíjení (BB/h) z §6.5.
- Pozn.: stávající fallbacky `UserProfile.getBodyBatteryHistory` / `getBodyBattery` v `SleepLogic.mc` v API neexistují (mrtvý kód) – odstranit.

### 6.2 Doporučený čas usnutí

Hledáme čas `T` (now ≤ T ≤ A), kdy platí: BB − d·(T − now) + r·(A − T) = G

  T = (BB − G + d·now + r·A) / (d + r)     (časy v hodinách)

- `T > now` → „Spát ve T“; BB při usnutí = BB − d·(T − now).
- `T ≤ now` a BB + r·(A − now) ≥ G → nemělo by nastat (pak by T > now); zaokrouhlovací hranice → „Jdi spát teď“.
- `T ≤ now` a BB + r·(A − now) < G → „Nestihne“: dosažitelné = min(100, BB + r·(A − now)).
- Stav „Jdi spát teď“ = T je v intervalu (now − 0, now + 10 min]. (Přesná šířka okna je na builderovi.)
- Pokud `T ≥ A` (BB je tak vysoko, že i bez spánku ≥ G) → stav „BB ≥ cíl / nabito“.
- Výsledky zaokrouhlit na celé minuty (zobrazení), interně bez zaokrouhlení.
- Odstraňuje se dosavadní úprava rychlosti podle tepu (HR vs RHR). HR/RHR se nadále nezobrazují (lze je ponechat jen pokud builder najde využití v detailu – není požadavek).

### 6.3 Sběr dat: vzorky BB na pozadí

- **Background služba** (`(:background)` ServiceDelegate, `Background.registerForTemporalEvent` po **30 min**, permission `Background`) přečte aktuální BB (`getBodyBatteryHistory` s `:period => 1`, stejně levné jako dnes) a zapíše vzorek `[čas, BB]` do **kruhového bufferu ve Storage** (posledních ~36 h, tj. ~72 vzorků po dvou číslech). Všechna zařízení s BB mají CIQ ≥ 3.3, takže zápis do Storage z backgroundu je dostupný.
- Když se spustí glance/widget, přidá do bufferu i svůj aktuální vzorek (jemnější data kolem večera/rána, kdy uživatel widget otevírá).
- Díky tomu se **nikdy nečte dlouhá historie BB** → žádné riziko OOM; učení funguje, i když uživatel widget večer ani ráno neotevře.
- Zpracování bufferu (detekce noci, výpočet `r` a `d`) běží ve foreground aplikaci/widgetu, ne v glance ani v backgroundu; výsledky (`r`, `d`, počet nocí, záznamy nocí) se uloží do Storage a glance je jen čte.

### 6.4 Automatická rychlost nabíjení `r`

- **Detekce skutečné noci z bufferu** (ne pevné okno z profilu – uživatel podle aplikace chodí spát v jiný čas než podle plánu):
  - široké okno = `sleepTime − 3 h` … `wakeTime + 3 h` z `UserProfile.getProfile()` (fallback: ruční budík, okno 18:00 … budík + 3 h),
  - **usnutí** = vzorek s minimem BB v první části okna, po kterém BB trvale roste; **probuzení** = vzorek s maximem BB, po kterém BB klesá (nebo konec okna). Přesný algoritmus na builderovi, s jednotkovými testy na typických i okrajových průbězích.
- Záznam noci: datum probuzení, čas a BB usnutí, čas a BB probuzení. Rychlost noci = ΔBB / hodiny mezi usnutím a probuzením.
- **Platná noc**: spánek ≥ 3 h, ΔBB > 0, rychlost 2–30 BB/h. Pokud BB dosáhlo 100 dřív než probuzení, za konec noci se bere první vzorek se 100 (jinak by se rychlost podhodnotila).
- Výsledná `r` = **medián** posledních max. **7 platných nocí** (odolné vůči jedné divné noci).
- **Minimum pro „auto“: 3 platné noci.** Do té doby se použije ruční hodnota a UI ukazuje „odhad · učím se N/3“.
- **Přepsání**: v nastavení „Rychlost nabíjení: Auto / Ruční“; ruční hodnota 1–30, **výchozí 10** (sjednotit – dnes je v kódu 11 a v properties 10).
- Noc se zpracuje nejvýše jednou (klíč = datum probuzení). Historie nocí na stránce 3 zobrazuje skutečnou délku spánku z detekce.

### 6.5 Večerní vybíjení `d`

- **Učí se z večerů**: pro každou zpracovanou noc se z bufferu spočítá tempo poklesu BB v posledních ~3 h před detekovaným usnutím (BB/h). Uloží se k záznamu noci.
- `d` = medián posledních max. 7 večerů, ohraničený 0–15 BB/h. **Výchozí bez dat: 3 BB/h.**
- Používá se **vždy naučená/výchozí hodnota**, ne aktuální sklon z posledních hodin – výpočet bedtime je tak stabilní přes den (ráno po běhu nevyjde nesmysl) a glance nemusí nic počítat z historie.
- Výjimka: pokud je teď méně než 3 h do vypočteného T, lze pro zpřesnění použít aktuální sklon z bufferu (ohraničený) – na builderovi, zda to přinese užitek.

## 7. Nastavení

Garmin Connect (mobilní app) i v hodinkách (Menu2):

| Klíč | Typ | Výchozí | Pozn. |
|---|---|---|---|
| `targetBB` | číslo 50–100 | 100 | cíl |
| `rateMode` | Auto / Ruční | Auto | |
| `baseRechargeRate` | číslo 1–30 | 10 | **zachovat klíč** kvůli stávajícím uživatelům |
| `wakeSource` | Garmin profil / Ruční | Garmin profil | |
| `wakeUpHour`, `wakeUpMinute` | čísla | 7 / 0 | **zachovat klíče** |
| (v hodinkách) Smazat naučená data | akce | – | s potvrzením |

Výběr času v hodinkách může být jednoduchý (hodiny/minuty po krocích); nemusí jít o plnohodnotný TimePicker.

**Migrace ze 2.x (jednorázově, příznak verze ve Storage):** pokud má uživatel budík jiný než výchozí 7:00, nastaví se `wakeSource = Ruční` (jeho budík se tedy po aktualizaci nezmění). `rateMode` je Auto pro všechny – dokud nejsou 3 noci, použije se jeho ruční rychlost, takže se nic nezmění skokově; detail ukazuje „učím se N/3“. Garmin plán spánku nemusí rozlišovat dny v týdnu (API vrací jednu hodnotu) – zmínit v příručce.

## 8. Architektura a kód

- `SleepModel` / kalkulačka: čisté funkce (výpočet T, stavů, dosažitelných %, agregace nocí) bez přístupu k senzorům → **unit testy** (`(:test)`, Run No Evil).
- Datová vrstva: čtení BB, profilu (wakeTime/sleepTime), historie s omezenou periodou.
- Úložiště učení: zápis/čtení nocí ve Storage, migrace (žádná předchozí data neexistují).
- Views: `GlanceView` (anotace `(:glance)`, minimum kódu), stránka 1–3, menu nastavení; společné kreslení (prstenec, barvy, formátování času) v helperu.
- Jeden delegate pro stránkovanou navigaci.
- Kreslení přímo přes `Dc` (ne XML layouty) je v pořádku a doporučené kvůli prstenci a škálování; konkrétní volba na builderovi.
- Odstranit debug `System.println` (případně jediný přepínač `DEBUG` konstantou), mrtvý kód, emoji v logech.
- Texty do `resources/strings` (`eng`) a `resources-ces/strings` (`ces`), v manifestu oba jazyky.
- `gen/` a `internal-mir/` jsou v `.gitignore`, ale soubory jsou v gitu – odebrat z indexu. Přidat `.superpowers/` do `.gitignore`.
- Zachovat `id` aplikace v manifestu (aktuálně `7330a3fc-…`) a typ `widget`; `minApiLevel` může zůstat 3.1.0 (glance od 3.1). Pokud některé zařízení glance nepodporuje, funguje jen klasický widget.
- Aktualizovat `README.md`, `Uživatelská_příručka.md`, `CHANGELOG.md` (verze 3.0). Ostatní staré dokumenty (`FINAL_SUMMARY.md`, `IMPLEMENTACE.md`, `Výpočet_Recharge_Rate.md`, `INSTALL_GUIDE.md`) aktualizovat nebo sloučit do README – **nemazat bez souhlasu**.
- Build skript `build_and_run.ps1` zachovat funkční.

## 9. Ověření

- Build bez varování na: `fenix843mm`, `fenix7`, `fenix6spro`, `fr245`, `venu2`, `vivoactive4s` (bez glance) (typecheck alespoň na úrovni, kterou projekt dnes projde).
- Unit testy výpočtu zelené (simulátor, `-t`).
- Ruční kontrola v simulátoru: glance, 3 stránky, navigace tlačítky i swipy, menu, všechny stavy z §5.1 (přes simulované hodnoty / dočasný debug vstup), čeština i angličtina, nejmenší a největší displej.
- Paměť glance a widgetu v simulátoru (View → Memory) pod limitem s rezervou na nejmenším zařízení.

## 10. Garmin Connect API (říjen 2026) – závěr

Program byl znovu otevřen ve třech úrovních: Personal (zdarma, 1 uživatel), Startup (zdarma, do 1 000 uživatelů), Enterprise (placený). Jde o **cloud API server-to-server** (data z Garmin Connect na backend vývojáře), ne o API pro hodinky. Pro widget by vyžadovalo vlastní server, OAuth a komunikaci hodinky → telefon → server. Přínos by byl hlavně přesnější data o spánku (skutečný začátek/konec, delší historie) pro učení rychlosti. **Pro 3.0 se nepoužije**; učení běží v hodinkách. Lze zvážit později, pokud by učení v hodinkách nebylo dost přesné.

## 11. Rozhodnutí, která udělal Claude (k odsouhlasení)

- Učení v hodinkách, bez serveru a bez Connect API.
- Sběr dat background službou každých 30 min do malého bufferu (nová permission `Background`) místo čtení dlouhé historie.
- Noc se detekuje ze skutečného průběhu BB, ne z plánu spánku.
- Večerní vybíjení se učí z předchozích večerů.
- Minimum 3 noci pro „auto“, medián 7 nocí, výchozí ruční rychlost 10, výchozí vybíjení 3 BB/h.
- Budík z Garmin profilu jako výchozí zdroj; stávající uživatelé s vlastním budíkem zůstanou na ručním.
- Odstranění HR/RHR úpravy a jejich zobrazení.
- Čeština + angličtina.
- Kreslení přes `Dc` místo XML layoutů.
- Odebrání fr645, fr645m a fr935 (nemají Body Battery API).

## 12. Na builderovi

- Přesná grafika (velikosti fontů, tloušťka prstence, ikony), pokud odpovídá mockupům a je čitelná na všech podporovaných displejích.
- Přesný algoritmus detekce usnutí/probuzení v mezích §6.4 a velikost bufferu.
- Šířka okna „Jdi spát teď“, cyklická vs. koncová navigace.
- Struktura souborů a pojmenování tříd.
