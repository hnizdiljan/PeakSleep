import Toybox.Lang;
import Toybox.Test;

(:test)
module TestData {

    function arraysEqual(a as Array, b as Array) as Boolean {
        if (a.size() != b.size()) {
            return false;
        }
        for (var i = 0; i < a.size(); i++) {
            if (a[i] != b[i]) {
                return false;
            }
        }
        return true;
    }

    // Samples every 30 min: evening 60 -> 50 (20:00-23:00), sleep from 23:00 rising
    // 3 per 30 min up to `peak` (capped at 100), then falling 2 per 30 min until 08:00.
    function typicalNightSamples(midnight as Number, peak as Number) as Array<Number> {
        var buf = [] as Array<Number>;
        var evening = [60, 58, 57, 55, 53, 52, 50];
        var t = midnight - 4 * 3600;
        for (var i = 0; i < evening.size(); i++) {
            buf.add(t);
            buf.add(evening[i]);
            t += 1800;
        }
        var bb = 50;
        var peaked = false;
        while (t <= midnight + 8 * 3600) {
            if (!peaked) {
                bb += 3;
                if (bb >= peak) {
                    bb = peak > 100 ? 100 : peak;
                    peaked = true;
                }
            } else if (peak < 100) {
                bb -= 2;
            }
            buf.add(t);
            buf.add(bb);
            t += 1800;
        }
        return buf;
    }
}

(:test)
function appendIgnoresNull(logger as Logger) as Boolean {
    Test.assert(TestData.arraysEqual(SampleBuffer.append([1, 2], 1000, null, 96, 600), [1, 2]));
    Test.assert(TestData.arraysEqual(SampleBuffer.append(null, 1000, null, 96, 600), []));
    return true;
}

(:test)
function appendReplacesWithinGap(logger as Logger) as Boolean {
    Test.assert(TestData.arraysEqual(SampleBuffer.append([0, 50], 300, 51, 96, 600), [300, 51]));
    Test.assert(TestData.arraysEqual(SampleBuffer.append([0, 50], 700, 52, 96, 600), [0, 50, 700, 52]));
    Test.assert(TestData.arraysEqual(SampleBuffer.append(null, 5, 40, 96, 600), [5, 40]));
    return true;
}

(:test)
function appendTrimsToCap(logger as Logger) as Boolean {
    Test.assert(TestData.arraysEqual(SampleBuffer.append([0, 1, 1000, 2], 2000, 3, 2, 600), [1000, 2, 2000, 3]));
    return true;
}

(:test)
function detectTypicalNight(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    // peak 95 is reached at 06:30 (15 half-hours after 23:00)
    var n = NightDetector.detect(TestData.typicalNightSamples(m, 95), m - 4 * 3600, m + 10 * 3600);
    Test.assert(n != null);
    var night = n as Night;
    Test.assertEqual(night.onsetT, m - 3600);
    Test.assertEqual(night.onsetBB, 50);
    Test.assertEqual(night.wakeT, m + (6.5 * 3600).toNumber());
    Test.assertEqual(night.wakeBB, 95);
    Test.assert(night.drain != null && (night.drain as Float) > 3.3 && (night.drain as Float) < 3.4);
    Test.assert(night.rate() > 5.9 && night.rate() < 6.1);
    Test.assert(NightDetector.isValid(night));
    return true;
}

(:test)
function detectSaturatedNight(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    // 50 + 3 per 30 min from 23:00 hits 100 at 07:30 (17 steps, capped), then stays flat
    var n = NightDetector.detect(TestData.typicalNightSamples(m, 100), m - 4 * 3600, m + 10 * 3600) as Night;
    Test.assertEqual(n.wakeBB, 100);
    // wake is the first sample at 100, not the end of the flat part
    Test.assertEqual(n.wakeT, m + (7.5 * 3600).toNumber());
    return true;
}

(:test)
function detectNoSamples(logger as Logger) as Boolean {
    Test.assert(NightDetector.detect([], 0, 1000) == null);
    // samples exist but all outside the window
    Test.assert(NightDetector.detect([5000, 40, 6000, 60], 0, 1000) == null);
    // falling only -> no night
    Test.assert(NightDetector.detect([0, 60, 1800, 50, 3600, 40], 0, 4000) == null);
    return true;
}

(:test)
function detectGapNight(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var n = NightDetector.detect([m - 3600, 50, m, 60], m - 4 * 3600, m + 10 * 3600);
    Test.assert(n != null);
    Test.assert(!NightDetector.isValid(n as Night));
    Test.assert((n as Night).drain == null);
    return true;
}

(:test)
function isValidRejectsHighRate(logger as Logger) as Boolean {
    // 0 -> 100 in 3 h = 33 BB/h
    Test.assert(!NightDetector.isValid(new Night(0, 0, 3 * 3600, 100, null)));
    // 1 -> 10 in 6 h = 1.5 BB/h
    Test.assert(!NightDetector.isValid(new Night(0, 1, 6 * 3600, 10, null)));
    Test.assert(NightDetector.isValid(new Night(0, 30, 8 * 3600, 94, null)));
    return true;
}

(:test)
function nightRoundTrip(logger as Logger) as Boolean {
    var n = Night.fromArray(new Night(1, 2, 3, 4, 2.5).toArray());
    Test.assertEqual(n.onsetT, 1);
    Test.assertEqual(n.wakeBB, 4);
    Test.assert(n.drain != null && (n.drain as Float) == 2.5);
    Test.assert(Night.fromArray(new Night(1, 2, 3, 4, null).toArray()).drain == null);
    return true;
}

(:test)
function medianOddEven(logger as Logger) as Boolean {
    Test.assertEqual(NightDetector.median([3.0, 1.0, 2.0]), 2.0);
    Test.assertEqual(NightDetector.median([4.0, 1.0, 2.0, 3.0]), 2.5);
    Test.assert(NightDetector.median([]) == null);
    return true;
}

(:test)
function isValidRejectsLongGap(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    // watch off/charging 21:00-07:00: only the two ends were sampled
    var buf = [m - 3 * 3600, 40, m + 7 * 3600, 90];
    var n = NightDetector.detect(buf, m - 4 * 3600, m + 10 * 3600);
    Test.assert(n != null);
    Test.assert(!NightDetector.isValid(n as Night));
    return true;
}
