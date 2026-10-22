# Výpočet rychlosti nabíjení a doporučeného času usnutí (verze 3.0)

> Verze 2.x používala ručně nastavenou rychlost a snižovala ji podle tepu. Ve verzi 3.0 je to
> nahrazené učením ze skutečných nocí a predikcí večerního vybíjení.

## 1. Sběr dat

- Background služba (`source/data/SampleService.mc`) se spouští každých 30 minut a ukládá
  dvojici `[čas, BB]` do kruhového bufferu ve Storage (`source/core/SampleBuffer.mc`, max. 96 vzorků = 48 h).
- Při otevření widgetu se přidá i aktuální vzorek. Vzorek bližší než 10 minut k předchozímu ho nahradí.
- Čte se vždy jen poslední hodnota (`getBodyBatteryHistory({:period => 1})`) – dlouhá historie
  způsobovala na některých hodinkách pád kvůli paměti.

## 2. Detekce noci (`source/core/NightDetector.mc`)

- Okno hledání: od (obvyklé usnutí − 3 h) do (obvyklé probuzení + 3 h) podle plánu spánku Garmin.
  Bez plánu: od 18:00 předchozího dne.
- **Usnutí** = nejnižší vzorek, po kterém následuje největší nárůst BB v okně.
- **Probuzení** = vzorek s maximem po usnutí; pokud BB dosáhla 100 dřív, bere se první vzorek se 100.
- **Rychlost noci** = (BB probuzení − BB usnutí) / hodiny mezi nimi.
- **Večerní vybíjení** = (BB 3 h před usnutím − BB usnutí) / hodiny, pokud data pokrývají aspoň 1 h;
  ohraničeno 0–15 BB/h.
- **Platná noc**: spánek ≥ 3 h a rychlost 2–30 BB/h.

## 3. Učení (`source/core/LearningMath.mc`, `source/data/Learning.mc`)

- Uchovává se posledních 7 platných nocí.
- Naučená rychlost = **medián** rychlostí, ale až od **3 platných nocí**.
- Naučené vybíjení = medián vybíjení (výchozí bez dat 3 BB/h).
- Každé okno se zpracuje jen jednou.

## 4. Doporučený čas usnutí (`source/core/BedtimeCalc.mc`)

Hledá se čas T (teď ≤ T ≤ budík), kdy platí:

    BB − d·(T − teď) + r·(budík − T) = cíl

    x = T − teď (hodiny) = (BB − cíl + r·H) / (d + r),   H = budík − teď

| Výsledek | Stav |
|---|---|
| BB neznámé, r ≤ 0 nebo d < 0 | Chybí data |
| x ≤ 10 min a do budíku dosáhneš cíle | Jdi spát teď |
| x ≤ 10 min a cíle nedosáhneš | Nestihneš – ukáže dosažitelné % |
| BB ≥ cíl | Nad cílem – případně „dnes spát ~T“ |
| jinak | Spát v T |

### Příklad

BB 54 %, cíl 100 %, budík za 8 h, nabíjení 10 BB/h, vybíjení 3 BB/h:

    x = (54 − 100 + 80) / 13 = 2,6 h  →  spát za 2 h 37 min, BB při usnutí 46 %

## 5. Testy

Všechny výpočty jsou čisté funkce s unit testy v `source/tests/` (`.\run_tests.ps1`).
