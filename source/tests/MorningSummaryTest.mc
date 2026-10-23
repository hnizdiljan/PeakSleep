import Toybox.Lang;
import Toybox.Test;

// typicalNightSamples: sleep from 23:00, BB 50 rising 3 per 30 min.
// peak 92 -> reached at 06:00, then falling; peak 100 -> reached at 07:30, then flat.

(:test)
function morningReachedTarget(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var buf = TestData.typicalNightSamples(m, 100);
    var s = MorningSummary.summarize(buf, m - 4 * h, m + 8 * h, m + (8.5 * h).toNumber(), 500, 100, [] as Array<Array>, m + 12 * h) as Array;
    Test.assertEqual(s[0], 100);
    Test.assertEqual(s[1], 0);
    Test.assertEqual(s[2], 0);
    Test.assertEqual(s[3], 1);
    return true;
}

(:test)
function morningBelowTargetIsLate(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var buf = TestData.typicalNightSamples(m, 92);
    var s = MorningSummary.summarize(buf, m - 4 * h, m + 8 * h, m + (8.5 * h).toNumber(), 500, 100, [] as Array<Array>, m + 12 * h) as Array;
    Test.assertEqual(s[0], 92);
    // 42 BB in 7 h = 6 BB/h, 8 BB missing -> 80 min
    Test.assertEqual(s[1], 80 * 60);
    Test.assertEqual(s[2], 1);
    Test.assertEqual(s[3], 0);
    return true;
}

(:test)
function morningNeedsSteps(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var buf = TestData.typicalNightSamples(m, 92);
    Test.assert(MorningSummary.summarize(buf, m - 4 * h, m + 8 * h, m + (8.5 * h).toNumber(), 20, 100, [] as Array<Array>, m + 12 * h) == null);
    return true;
}

(:test)
function morningNeedsBbToStopRising(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var buf = TestData.typicalNightSamples(m, 92);
    // at 06:00 the peak is still the newest sample
    Test.assert(MorningSummary.summarize(buf, m - 4 * h, m + 6 * h, m + 6 * h, 500, 100, [] as Array<Array>, m + 12 * h) == null);
    return true;
}

(:test)
function morningEndsAtNoon(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var buf = TestData.typicalNightSamples(m, 92);
    Test.assert(MorningSummary.summarize(buf, m - 4 * h, m + 8 * h, m + (12.5 * h).toNumber(), 500, 100, [] as Array<Array>, m + 12 * h) == null);
    return true;
}

(:test)
function morningShowsTwoHoursAfterLateWake(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    // same night shifted by 5 h: wake (peak) at 11:00, still shown at 12:30
    var buf = TestData.typicalNightSamples(m + 5 * h, 92);
    var s = MorningSummary.summarize(buf, m + h, m + 13 * h, m + (12.5 * h).toNumber(), 500, 100, [] as Array<Array>, m + 12 * h);
    Test.assert(s != null);
    return true;
}

(:test)
function morningStreakSkipsSameNightAndCountsBack(logger as Logger) as Boolean {
    var m = 10 * TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var d = TimeUtil.DAY;
    var buf = TestData.typicalNightSamples(m, 92);
    var stored = [
        new Night(m - 3 * d - h, 40, m - 3 * d + 7 * h, 100, 2.0).toArray(),
        new Night(m - 2 * d - h, 40, m - 2 * d + 7 * h, 85, 2.0).toArray(),
        new Night(m - d - h, 40, m - d + 7 * h, 90, 2.0).toArray(),
        // tonight, already learned by the widget
        new Night(m - h, 50, m + 6 * h, 92, 2.0).toArray()
    ] as Array<Array>;
    var s = MorningSummary.summarize(buf, m - 4 * h, m + 8 * h, m + (8.5 * h).toNumber(), 500, 100, stored, m + 12 * h) as Array;
    Test.assertEqual(s[2], 3);
    Test.assertEqual(s[3], 0);
    // with target 90 the last three reached it
    s = MorningSummary.summarize(buf, m - 4 * h, m + 8 * h, m + (8.5 * h).toNumber(), 500, 90, stored, m + 12 * h) as Array;
    Test.assertEqual(s[2], 0);
    Test.assertEqual(s[3], 2);
    return true;
}
