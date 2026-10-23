# Peak Sleep

Peak Sleep is a Garmin Connect IQ widget that answers one question:
**"When should I go to bed to wake up with a full Body Battery?"**

It learns how fast your Body Battery recharges at night and how fast it drains in the
evening from your own nights, and shows the answer right in the glance list:

> ☾ **Sleep at 22:40** — in 1 h 20 min · BB 54%

## Screens

| Where | What you see |
|---|---|
| **Glance** | Bedtime and a detail line. Colors: yellow = plan, blue = go to sleep now, red = target out of reach, green = already above target. |
| **Page 1 – Answer** | Body Battery ring (the darker part is the drain predicted until bedtime), bedtime, countdown, Body Battery at bedtime and the target. |
| **Morning** (glance and page 1) | After waking up until noon: "Charged to 92%", whether bedtime was on time ("35 min late") and the streak of nights below / at target. Wake-up is detected when Body Battery stops rising and at least 100 steps have been walked. |
| **Page 2 – Why** | Inputs of the calculation: Body Battery now, evening drain, recharge rate and its source (auto / learning / manual), target. |
| **Page 3 – Last nights** | Recharge rate of the last up to 7 learned nights (green = target reached) with average rate and sleep length. |

**Navigation:** Down / swipe up = next page, Up / swipe down = previous page, Back = leave,
Menu (long press Up) = settings. On devices without glances (Venu, vívoactive 4/4S) page 1 lives in
the widget loop; press Select to open the other pages.

## How it works

1. A background service stores one Body Battery sample every 30 minutes (only the latest value is
   read, never long history, to avoid out-of-memory crashes on older watches).
2. When the widget is opened, the last two nights are detected from the samples: the lowest point in
   the evening is when you fell asleep, the highest point in the morning (or the first 100%) is when you
   woke up. Opening the widget at least every other day is enough; nights with a sampling gap over
   2 hours (watch off or charging) are ignored.
3. Recharge rate = Body Battery gained / hours slept. Evening drain = Body Battery lost in the
   3 hours before falling asleep. Both use the median of the last 7 valid nights.
4. Bedtime T solves: `BB − drain·(T − now) + rate·(alarm − T) = target`, with the evening drain
   stopping at Garmin's Body Battery floor of 5.

Until 3 valid nights are learned the manual recharge rate is used and the app shows
"estimate · learning N/3".

## Settings

Available in Garmin Connect and in the on-watch menu:

| Setting | Default |
|---|---|
| Target Body Battery (50–100 %) | 100 |
| Recharge rate: Auto (learned) / Manual | Auto |
| Manual recharge rate (1–30 BB/h) | 10 |
| Alarm source: Garmin sleep schedule / Manual | Garmin sleep schedule |
| Alarm hour / minute | 7:00 |

The watch menu also offers **Reset learned data**.

## Supported devices

29 Connect IQ devices with Body Battery: fēnix 6/7/8 series, Forerunner 245, 745, 945 (LTE), 955,
965, Venu, Venu 2, vívoactive 4/4S/5/6 (see `manifest.xml`). Forerunner 645 and 935 were dropped in
3.0 because their firmware has no Body Battery API.

## Languages

English, Czech.

## Permissions

- **Background** – sampling Body Battery every 30 minutes for learning
- **SensorHistory** – reading the current Body Battery
- **UserProfile** – sleep schedule (wake / sleep time)

## Development

Requires the Connect IQ SDK (8.x) and a `developer_key` in the project root.

```powershell
.\build_and_run.ps1 -Device fenix843mm   # build and run in the simulator
.\run_tests.ps1                         # unit tests in the simulator
```

Code layout:

- `source/core` – pure logic (time math, bedtime calculation, night detection, settings)
- `source/data` – Body Battery reader, background sampling, learning storage
- `source/ui` – glance, pages, settings menu
- `source/tests` – unit tests (`(:test)`)

Design: `docs/superpowers/specs/2026-10-22-peaksleep-redesign-design.md`.
