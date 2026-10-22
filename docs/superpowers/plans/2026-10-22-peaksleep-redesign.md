# PeakSleep 3.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild PeakSleep as a glance + 3-page widget that tells the user when to go to bed to reach the target Body Battery by the alarm, learning recharge and evening-drain rates from their own nights.

**Architecture:** Pure, unit-tested core modules (time math, bedtime calculation, night detection, ring buffer, settings parsing) with no Toybox sensor access; a thin data layer (BB reader, Storage-backed sample buffer and learning store) shared by a 30-min background service, the glance and the foreground; Dc-drawn views (glance, Answer, Detail, History) and a Menu2 settings menu.

**Tech Stack:** Monkey C, Connect IQ SDK 8.1.1 (`C:\Garmin\Sdks\connectiq-sdk-win-8.1.1-2025-03-27-66dae750f`), Toybox.Test unit tests, simulator via `connectiq` / `monkeydo`.

**Spec:** `docs/superpowers/specs/2026-10-22-peaksleep-redesign-design.md`

## Global Constraints

- App id `7330a3fc-922b-405b-a047-72a0273d0a7d`, type `widget`, `minApiLevel="3.1.0"` stay unchanged.
- Products: current list minus `fr645`, `fr645m`, `fr935` (29 products).
- Permissions: `Sensor`, `SensorHistory`, `UserProfile`, **`Background`** (new).
- Languages: `eng` (default `resources/`) and `ces` (`resources-ces/`). No user-visible string literals in `.mc` except numeric formats.
- Property keys kept: `baseRechargeRate` (default **10**, 1–30), `wakeUpHour` (7), `wakeUpMinute` (0). New: `targetBB` (100, 50–100), `rateMode` (0=Auto,1=Manual; default 0), `wakeSource` (0=Garmin profile,1=Manual; default 0).
- Learning: min **3** valid nights for auto, median of last **7**, valid night ≥ 3 h sleep, ΔBB > 0, rate 2–30 BB/h; drain = median of last 7 evenings, clamp 0–15, default **3.0** BB/h; background sample every **30 min**.
- Never read BB history with a period longer than 1 sample (OOM anti-goal). Glance only reads Storage, never writes.
- Glance/background memory 32 KB on fenix6*, fr245, fr745, fr945(lte): code annotated `(:glance)` / `(:background)` must stay minimal.
- No `System.println` left in shipped code paths.
- Build command (any device): `monkeyc -f monkey.jungle -o bin/PeakSleep.prg -y developer_key -d <device> -w`
- Test command: `monkeyc -f monkey.jungle -o bin/test.prg -y developer_key -d fenix843mm -t` then `monkeydo bin/test.prg fenix843mm /t` (simulator `connectiq` must be running). Expected tail: `RESULTS` table with all `PASS`.

## Review Focus

1. Time after midnight but before alarm (e.g. 01:30, alarm 06:30) → alarm is *today*, plan uses 5 h, never tomorrow. (Task 1 test `nextAlarmAfterMidnight`)
2. Watch off/charging overnight, buffer has gaps or no samples in window → night is invalid and learned values unchanged, no crash. (Task 3 tests `detectNoSamples`, `detectGapNight`)
3. Properties missing or wrong type after upgrade from 2.x (null, Float instead of Number) → defaults/clamped values. (Task 4 test `numOrHandlesNullAndFloat`)
4. Background sample returns null BB (sensor not ready) → no sample stored, service exits cleanly. (Task 5 step, verified by `SampleBuffer.append` never called with null — test `appendIgnoresNull`)
5. Degenerate rates: rate 0/negative or rate+drain = 0 → plan state `STATE_NO_DATA`, no division by zero. (Task 2 test `computeZeroRate`)

---

### Task 1: Test harness, repo hygiene, TimeUtil

**Files:**
- Create: `source/core/TimeUtil.mc`, `source/tests/TimeUtilTest.mc`
- Modify: `.gitignore` (add `.superpowers/`), untrack `gen/` and `internal-mir/` (`git rm -r --cached gen internal-mir`)

**Interfaces — Produces** (module `TimeUtil`, annotated `(:glance)`):
- `const DAY = 86400; const HOUR = 3600;`
- `function nextAlarm(todayMidnight as Number, now as Number, wakeSecOfDay as Number) as Number` – first `todayMidnight + wakeSecOfDay (+86400·k)` strictly after `now`.
- `function sleepWindow(todayMidnight as Number, now as Number, sleepSecOfDay as Number?, wakeSecOfDay as Number) as [Number, Number]` – most recent window `[ws, we]` with `we <= now`, where `we = wake + 3 h` on the wake day and `ws = (sleepSecOfDay on previous evening) − 3 h`; if `sleepSecOfDay == null`, `ws = 18:00 of previous day`. If sleepSec > wakeSec it belongs to the previous day, otherwise same day.
- `function formatDuration(sec as Number) as String` – `"1 h 20 min"`, `"45 min"`, `"0 min"` for ≤ 0; minutes rounded down.
- `function czechVe(hour as Number) as Boolean` – true for 2,3,4,12,13,14,20,21,22,23.
- `function pluralIndex(n as Number) as Number` – 0 for 1, 1 for 2–4, 2 otherwise.

- [ ] **Step 1: Write failing tests** in `source/tests/TimeUtilTest.mc` (each `(:test) function x(logger as Logger) as Boolean`):
  - `nextAlarmEvening`: midnight=0, now=22·H, wake=6.5·H → `DAY + 6.5·H`.
  - `nextAlarmAfterMidnight`: now=1.5·H, wake=6.5·H → `6.5·H`.
  - `nextAlarmExactlyAtAlarm`: now=6.5·H → `DAY + 6.5·H`.
  - `sleepWindowMorning`: midnight=10·DAY, now=10·DAY+12·H, sleep=23·H, wake=7·H → `[10·DAY − H − 3·H, 10·DAY + 10·H]`.
  - `sleepWindowBeforeEnd`: now=10·DAY+8·H (before we) → previous window `[9·DAY − 4·H, 9·DAY + 10·H]`.
  - `sleepWindowNoSleepTime`: sleep=null → `ws = 10·DAY − 6·H`.
  - `formatDurationCases`: 4800→"1 h 20 min", 2700→"45 min", 0→"0 min", 3600→"1 h 0 min".
  - `czechVeCases`, `pluralCases` (1→0, 3→1, 5→2, 0→2, 11→2).
- [ ] **Step 2: Run tests** (test command) → compile FAIL (TimeUtil missing).
- [ ] **Step 3: Implement `TimeUtil`.**
- [ ] **Step 4: Run tests** → all PASS.
- [ ] **Step 5: Commit** `refactor: add TimeUtil with unit tests and clean tracked build output`.

### Task 2: BedtimeCalc

**Files:** Create `source/core/BedtimeCalc.mc`, `source/tests/BedtimeCalcTest.mc`

**Interfaces — Produces** (`(:glance)`):
- Module `BedtimeCalc`: `STATE_NO_DATA = 0, STATE_PLAN = 1, STATE_NOW = 2, STATE_LATE = 3, STATE_CHARGED = 4`, `NOW_WINDOW = 600`.
- Class `BedtimePlan` with public vars: `state as Number`, `bedtime as Number?` (epoch s), `bbAtBed as Number?`, `reachable as Number?`, `alarm as Number`, `bb as Number?`.
- `function compute(bb as Number?, target as Number, now as Number, alarm as Number, rate as Float, drain as Float) as BedtimePlan`

Algorithm (hours: `H = (alarm−now)/3600`): `x = (bb − target + rate·H) / (drain + rate)`.
- `bb == null` or `rate <= 0` or `drain < 0` → NO_DATA.
- `x <= NOW_WINDOW/3600`: reachable = min(100, round(bb + rate·H)); `reachable >= target` → NOW (bedtime=now, bbAtBed=bb) else LATE (bedtime=now).
- else bedtime = now + round(x·3600); bbAtBed = round(bb − drain·x); if `bb >= target` → CHARGED (bedtime = null when `x >= H`) else PLAN.

- [ ] **Step 1: Tests**: `computePlan` (bb=54, target=100, now=0, alarm=8·H, rate=10, drain=3 → x=(−46+80)/13=2.615 h → state PLAN, bedtime=9415±1, bbAtBed=46); `computeNow` (bb=20, rate=10, H=8, drain=3 → x=0 ⇒ NOW, reachable=100); `computeLate` (bb=10, H=5 → LATE, reachable=60); `computeCharged` (bb=96, H=20, drain=3 → x=(−4+200)/13=15.08 → CHARGED, bedtime non-null); `computeChargedNoSleepNeeded` (bb=100, H=2, drain=0 → x≥H → CHARGED, bedtime null); `computeNoBb`; `computeZeroRate` (rate 0 and rate+drain=0 → NO_DATA).
- [ ] **Step 2: Run** → FAIL. **Step 3: Implement.** **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat: add BedtimeCalc with evening drain`.

### Task 3: SampleBuffer, NightDetector, median

**Files:** Create `source/core/SampleBuffer.mc` (`(:background)`), `source/core/NightDetector.mc`, `source/tests/NightDetectorTest.mc`

**Interfaces — Produces:**
- `SampleBuffer.append(buf as Array<Number>?, t as Number, bb as Number?, maxPairs as Number, minGap as Number) as Array<Number>` – flat `[t0,bb0,t1,bb1,…]`; null bb → buffer unchanged (null buf → `[]`); if last `t` is within `minGap` → replace last pair; trims oldest pairs over `maxPairs`. Constants `MAX_PAIRS = 96`, `MIN_GAP = 600`.
- Class `Night`: `onsetT, onsetBB, wakeT, wakeBB as Number`, `drain as Float?`; `function rate() as Float` (BB/h); `function toArray() as Array`; `static function fromArray(a as Array) as Night`.
- `NightDetector.detect(buf as Array<Number>, ws as Number, we as Number) as Night?` – max-rise pair (i<j) inside window; if a sample with BB ≥ 100 occurs between i and j, wake = first such; drain from samples in `[onsetT − 3 h, onsetT]` when span ≥ 1 h: `(bbFirst − onsetBB)/hours`, clamped 0–15, else null. Returns null when < 2 samples in window or rise ≤ 0.
- `NightDetector.isValid(n as Night) as Boolean` – sleep ≥ 3 h and 2 ≤ rate ≤ 30.
- `NightDetector.median(vals as Array<Float>) as Float?`

- [ ] **Step 1: Tests**: `appendIgnoresNull`, `appendReplacesWithinGap`, `appendTrimsToCap`; `detectTypicalNight` (samples every 30 min: evening 60→50 from 20:00–23:00, sleep 23:00 BB 50 rising to 06:30 BB 95, then falling → onset 23:00/50, wake 06:30/95, drain≈3.3); `detectSaturatedNight` (hits 100 at 04:00, flat to 07:00 → wake 04:00); `detectNoSamples` → null; `detectGapNight` (only 2 samples 1 h apart → detect returns night but `isValid` false); `isValidRejectsHighRate` (rate 40); `medianOddEven` ([3,1,2]→2, [1,2,3,4]→2.5, []→null).
- [ ] **Step 2–4:** FAIL → implement → PASS.
- [ ] **Step 5: Commit** `feat: add night detection and sample ring buffer`.

### Task 4: Settings

**Files:** Create `source/core/Settings.mc` (`(:glance)`), `source/tests/SettingsTest.mc`; replace `resources/properties/properties.xml`, `resources/settings/settings.xml`

**Interfaces — Produces** (module `Settings`):
- `RATE_AUTO = 0, RATE_LEARNING = 1, RATE_MANUAL = 2` (rate sources); `DEFAULT_DRAIN = 3.0`, `MIN_NIGHTS = 3`.
- `function numOr(v, def as Number, min as Number, max as Number) as Number` – Number/Float/Long → clamped Number, otherwise def.
- `function target() as Number`, `function autoRate() as Boolean`, `function manualRate() as Float`, `function useProfileWake() as Boolean`, `function manualWakeSec() as Number`
- `function wakeSecOfDay() as Number` – profile `wakeTime` if `useProfileWake()` and non-null, else manual.
- `function sleepSecOfDay() as Number?` – profile `sleepTime`.
- `function resolveRate(auto as Boolean, learned as Float?, nights as Number, manual as Float) as [Float, Number]` – `[learned, RATE_AUTO]` if auto and learned≠null; `[manual, RATE_LEARNING]` if auto; else `[manual, RATE_MANUAL]`.
- `function set(key as String, value as Number) as Void` (foreground only, wraps `Properties.setValue`).
- `function migrate() as Void` (foreground only): if Storage `ver` null → if manual wake ≠ 7:00 set `wakeSource=1`; set Storage `ver=3`.

- [ ] **Step 1: Tests**: `numOrHandlesNullAndFloat` (null→def, 11.7→11, 500→max, "x"→def); `resolveRateCases` (all three branches).
- [ ] **Step 2–4:** FAIL → implement → PASS.
- [ ] **Step 5: properties.xml / settings.xml** with the keys in Global Constraints; list settings for `rateMode`, `wakeSource` (`settingConfig type="list"` + `listEntry`), numeric for the rest; titles from strings `setTarget`, `setRateMode`, `setRate`, `setWakeSource`, `setWakeHour`, `setWakeMinute`, `optAuto`, `optManual`, `optProfile`.
- [ ] **Step 6: Build** (build command, fenix843mm) → BUILD SUCCESSFUL. **Commit** `feat: add settings module and new properties`.

### Task 5: Data layer, background sampling, learning

**Files:** Create `source/data/BodyBatteryReader.mc` (`(:background :glance)`), `source/data/SampleService.mc` (`(:background)`), `source/data/Learning.mc`; Modify `source/PeakSleepApp.mc`, `manifest.xml` (permission `Background`)

**Interfaces:**
- Consumes: `SampleBuffer.append`, `NightDetector.*`, `TimeUtil.sleepWindow`, `Settings.*`.
- Produces:
  - `BodyBatteryReader.read() as Number?` – `SensorHistory.getBodyBatteryHistory({:period => 1})` first sample, guarded by `has` checks; null otherwise. (Drop the nonexistent `UserProfile` fallbacks.)
  - `SampleService extends System.ServiceDelegate`: `onTemporalEvent()` → `Storage.setValue("samples", SampleBuffer.append(Storage.getValue("samples"), now, read(), MAX_PAIRS, MIN_GAP))` in try/catch, then `Background.exit(null)`.
  - Module `Learning` (foreground): `function recordSample() as Void`; `function update(now as Number) as Void` (process the latest finished window once – key `lastWin` = we; store valid nights in `nights` (max 7, newest last, as arrays); write `lr` = median rates if ≥ 3 nights else null, `ld` = median drains (non-null) or null, `nc` = count); `function nights() as Array<Night>`; `function reset() as Void` (clears samples, nights, lastWin, lr, ld, nc).
  - Glance-safe reads in `Learning` are **not** used by the glance; glance reads `lr`, `ld`, `nc` directly via `Storage.getValue` in a `(:glance)` helper `PlanBuilder.build(now as Number) as [BedtimePlan, Number, Number]` (plan, rate source, night count) placed in `source/core/PlanBuilder.mc`.
  - `PeakSleepApp` annotated `(:background :glance)`: `getServiceDelegate()` returns `[new SampleService()]`; `ensureBackground()` registers `Background.registerForTemporalEvent(new Time.Duration(1800))` when `getTemporalEventRegisteredTime() == null`; called from `getInitialView()` and `getGlanceView()`.
- [ ] **Step 1:** Implement the files. **Step 2: Build** fenix843mm and fenix6spro → BUILD SUCCESSFUL.
- [ ] **Step 3: Simulator check**: run in simulator, *Simulation → Background Events → trigger temporal event*, confirm in *File → View Application Data/Storage* that `samples` gets a pair. Check *View → Memory* for background stays well under 32 KB on fenix6spro.
- [ ] **Step 4: Commit** `feat: background BB sampling and on-device learning`.

### Task 6: Theme and glance

**Files:** Create `source/ui/Theme.mc` (`(:glance)`), `source/ui/PeakGlanceView.mc` (`(:glance)`); Modify `PeakSleepApp.mc`

**Interfaces — Produces:**
- `Theme`: colors `C_YELLOW = 0xF5C400, C_BLUE = 0x7FB2FF, C_RED = 0xFF5A4F, C_GREEN = 0x4CD964, C_DIM = 0xAAAAAA, C_TRACK = 0x222222`; `function stateColor(state as Number) as Number`; `function hm(epoch as Number) as String` (HH:MM, `Gregorian.info(..., FORMAT_SHORT)`); `function sleepAtPrefix(epoch as Number, upper as Boolean) as String` (picks `sleepAtV`/`sleepAtVe` or `labelSleepAtV`/`labelSleepAtVe` via `TimeUtil.czechVe`); `function drawMoon(dc, x, y, r) as Void` (filled circle minus offset circle in background color).
- `PeakGlanceView extends WatchUi.GlanceView`: `onUpdate(dc)` draws moon + two lines for every row of spec §5.1 (states + learning text + no data) using `PlanBuilder.build`.
- `getGlanceView()` in app → `[new PeakGlanceView()]`.
- [ ] **Step 1:** Implement. **Step 2: Build** fenix843mm, fr245 → SUCCESS. **Step 3: Simulator**: glance shows "Spát ve HH:MM" / second line; set BB via *Simulation → Body Battery* (or Activity Monitor data) to 100 and 10 to see CHARGED / LATE colors; glance memory well under 32 KB on fr245.
- [ ] **Step 4: Commit** `feat: add glance`.

### Task 7: Pages and navigation

**Files:** Create `source/ui/AnswerView.mc`, `source/ui/DetailView.mc`, `source/ui/HistoryView.mc`, `source/ui/PageDelegate.mc`; Modify `PeakSleepApp.mc`; Delete `source/PeakSleepView.mc`, `source/PeakSleepDelegate.mc`, `source/BedtimeAdvisorView.mc`, `source/BedtimeAdvisorDelegate.mc`, `source/SleepLogic.mc`, `source/PeakSleep-settings.json`, `resources/layouts/*`, unused drawables (keep `launcher_icon.png`).

**Interfaces:**
- Consumes: `PlanBuilder.build`, `Learning.nights/update/recordSample`, `Theme.*`, `TimeUtil.formatDuration`.
- Produces: `PageDelegate.initialize(index as Number, inCarousel as Boolean)`; pages indexed 0=Answer,1=Detail,2=History; `function makePage(index as Number) as WatchUi.View`.
- AnswerView: BB ring (`drawArc`, pen ≈ 4 % of width, start 90°, clockwise; bright segment = bbAtBed..bb shown darker shade `0x6B5600`, i.e. bright arc for bbAtBed, dark arc from bbAtBed to bb), label, big time (`FONT_NUMBER_MEDIUM`), "za …", bottom lines per spec §5.2, "⌄" hint (small chevron drawn with lines). Calls `Learning.recordSample()` + `Learning.update(now)` in `onShow`; 60 s refresh timer, stopped in `onHide`.
- Navigation per spec §5.5: if `System.getDeviceSettings().isGlanceModeEnabled` (guard with `has`) → initial view page 0, next/prev via `switchToView`, Back exits (`popView`), last page stops (no wrap). Otherwise (`inCarousel`) page 0 `onSelect` pushes page 1; next/prev on page 0 return false; on pages 1–2 next/prev switch between them; Back pops to page 0. `onMenu` opens settings menu (Task 8; until then returns false).
- [ ] **Step 1:** Implement. **Step 2: Build** fenix843mm, vivoactive4s, fr245 → SUCCESS, no warnings about removed resources.
- [ ] **Step 3: Simulator**: buttons + swipes on fenix843mm and vivoactive4s follow §5.5; all text fits on fr245 (smallest) and fenix8 47 mm.
- [ ] **Step 4: Commit** `feat: new answer/detail/history pages and navigation`.

### Task 8: On-watch settings menu

**Files:** Create `source/ui/SettingsMenu.mc` (Menu2 + `Menu2InputDelegate`), `source/ui/StepperView.mc` (value picker: up/down change, select confirm, back cancel)

**Interfaces:**
- `SettingsMenu.open() as Void` – pushes Menu2 with items: Target (`targetBB`, 50–100 step 5), Recharge rate (Auto/Manual toggle `rateMode`), Manual rate (1–30 step 1), Alarm source (profile/manual `wakeSource`), Alarm hour (0–23), Alarm minute (0–55 step 5), Reset learned data (`WatchUi.Confirmation` → `Learning.reset()`).
- `StepperView.initialize(title as String, value as Number, min as Number, max as Number, step as Number, onDone as Method(v as Number) as Void)`.
- Sublabels show current values; changes call `Settings.set` then `WatchUi.requestUpdate()`.
- [ ] **Step 1:** Implement, wire `onMenu` in `PageDelegate`. **Step 2: Build** → SUCCESS. **Step 3: Simulator**: change target to 90 → answer page and glance reflect it; reset clears History.
- [ ] **Step 4: Commit** `feat: on-watch settings menu`.

### Task 9: Localization, manifest, docs, multi-device build

**Files:** `resources/strings/strings.xml` (eng, final), create `resources-ces/strings/strings.xml`; `manifest.xml`; `README.md`, `Uživatelská_příručka.md`, `CHANGELOG.md` (3.0), fold `FINAL_SUMMARY.md` / `IMPLEMENTACE.md` / `Výpočet_Recharge_Rate.md` / `INSTALL_GUIDE.md` content updates (do not delete); `build_and_run.ps1` (output to `bin/`).
- [ ] **Step 1:** Czech strings for every eng id; manifest languages `eng`, `ces`; products per Global Constraints.
- [ ] **Step 2: Build all**: loop over `fenix843mm fenix7 fenix6spro fr245 venu2 vivoactive4s` with build command → all BUILD SUCCESSFUL; run tests → all PASS.
- [ ] **Step 3: Simulator** in Czech (*Settings → Language*): glance + pages show Czech, "v"/"ve" correct.
- [ ] **Step 4: Commit** `docs: Czech localization, manifest and documentation for 3.0`.

### Task 10: Final review

- [ ] Whole-branch review against the spec (use superpowers:requesting-code-review), fix findings, rebuild + tests.
