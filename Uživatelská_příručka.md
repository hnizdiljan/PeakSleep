# Peak Sleep – Uživatelská příručka

Peak Sleep ti řekne, **v kolik jít spát, aby ses do budíku dobil na 100 % Body Battery** (nebo na
jiný cíl, který si nastavíš).

## Rychlý start

1. Nainstaluj widget a přidej ho do seznamu widgetů (glances).
2. V Garmin Connect měj nastavený **plán spánku** (čas usínání a buzení) – widget z něj bere čas budíku.
3. Večer se podívej do seznamu widgetů: „☾ **Spát ve 22:40** – za 1 h 20 min · BB 54 %“.

První 3 noci se widget učí. Do té doby používá ruční rychlost nabíjení (výchozí 10 BB/h) a ukazuje
„odhad · učím se N/3“.

## Co ukazuje glance (řádek v seznamu widgetů)

| Situace | Řádek 1 | Řádek 2 |
|---|---|---|
| Ještě je čas | Spát ve **22:40** (žlutě) | za 1 h 20 min · BB 54 % |
| Je čas jít spát | **Jdi spát teď** (modře) | 100 % do 6:30 · BB 48 % |
| Cíl už nestihneš | Spát hned | do budíku jen **85 %** (červeně) |
| BB je nad cílem | **BB 96 %** (zeleně) | dnes spát ~23:10 |
| Učí se | Spát ve 22:40 | odhad · učím se 2/3 |
| Chybí data | Peak Sleep | Body Battery nedostupné |
| Ráno po probuzení | **Nabito na 92 %** (zeleně = cíl, žlutě = do 15 bodů pod, červeně = víc) | pozdě o 35 min · 3 noci pod cílem |

**Ranní souhrn** se ukáže, když Body Battery po noci přestane růst a od půlnoci ujdeš aspoň 100 kroků
(vzorky se berou po 30 minutách, takže zhruba 30–60 minut po vstání). Zůstane do poledne, nejméně 2 hodiny
po probuzení. „Pozdě o 35 min“ znamená, o kolik dřív bys musel usnout, abys s rychlostí nabíjení té noci
dosáhl cíle. Série počítá noci po sobě pod cílem / na cíli. Skutečnou délku spánku ani spánkovou
deprivaci Garmin aplikacím nezpřístupňuje, série nedobitých nocí je nejbližší náhrada.

## Stránky widgetu

1. **Odpověď** – prstenec po obvodu ukazuje Body Battery. Tmavší část je to, co ještě večer
   vybiješ do usnutí. Uprostřed čas usnutí, odpočet, BB při usnutí a cíl.
2. **Proč** – z čeho výpočet vychází: BB teď, večerní vybíjení, rychlost nabíjení (auto · počet nocí /
   učím se / ruční) a cíl.
3. **Poslední noci** – sloupce rychlosti nabíjení za posledních až 7 nocí. Zelená = noc dosáhla cíle.

**Ovládání:** Dolů / přejetí nahoru = další stránka, Nahoru / přejetí dolů = předchozí, Zpět = odchod,
Menu (dlouhý stisk Nahoru) = nastavení. Na hodinkách bez glance (Venu, vívoactive 4/4S) je stránka 1
přímo ve smyčce widgetů a další stránky otevřeš tlačítkem Select / klepnutím.

## Nastavení

V aplikaci Garmin Connect i přímo v hodinkách (Menu):

- **Cílová Body Battery** (50–100 %, výchozí 100)
- **Rychlost nabíjení** – Auto (naučená) nebo Ruční
- **Ruční rychlost nabíjení** (1–30 BB/h, výchozí 10) – použije se v ručním režimu a dokud se widget učí
- **Zdroj budíku** – Plán spánku Garmin nebo Ruční
- **Hodina / minuta budíku** – pro ruční zdroj
- **Smazat naučená data** (jen v hodinkách)

Plán spánku v Garmin Connect může mít různé časy pro různé dny, aplikace ale od Garminu dostane jen
jeden „typický“ čas. Pokud vstáváš každý den jinak, nastav budík ručně.

Při aktualizaci ze starší verze: pokud jsi měl nastavený vlastní budík (jiný než 7:00), zůstane zdroj
budíku „Ruční“.

## Jak to počítá

- Hodinky si každých 30 minut na pozadí uloží aktuální Body Battery.
- Při otevření widgetu (ne jen glance) se v datech najdou poslední 2 noci: nejnižší bod večer = usnutí,
  nejvyšší bod ráno (nebo první 100 %) = probuzení. Rychlost nabíjení = získané body / hodiny spánku.
  **Stačí otevřít widget aspoň jednou za 2 dny**, jinak se starší noc ztratí.
- Noc, ve které hodinky víc než 2 hodiny nesbíraly data (vypnuté, nabíjení), se nezapočítá.
- Večerní vybíjení = kolik BB ubylo za 3 hodiny před usnutím.
- Z posledních 7 platných nocí se bere medián (jedna divná noc výsledek nerozhodí). Platná noc má
  alespoň 3 hodiny spánku a rychlost 2–30 BB/h.
- Body Battery podle Garminu neklesne pod 5 %, takže večerní vybíjení se tam zastaví.
- Čas usnutí T se spočítá tak, aby platilo: BB teď − vybíjení·(T − teď) + nabíjení·(budík − T) = cíl.

Podrobnosti: `Výpočet_Recharge_Rate.md`.

## Podporované hodinky

fēnix 6/7/8, Forerunner 245, 745, 945 (LTE), 955, 965, Venu, Venu 2, vívoactive 4/4S/5/6.
Forerunner 645 a 935 od verze 3.0 podporované nejsou – jejich firmware nemá API pro Body Battery.
