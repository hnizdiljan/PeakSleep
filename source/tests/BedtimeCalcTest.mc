import Toybox.Lang;
import Toybox.Test;

(:test)
function computePlan(logger as Logger) as Boolean {
    var p = BedtimeCalc.compute(54, 100, 0, 8 * 3600, 10.0, 3.0);
    Test.assertEqual(p.state, BedtimeCalc.STATE_PLAN);
    // x = (54 - 100 + 80) / 13 h = 2.615 h = 9415 s
    Test.assert(p.bedtime != null && (p.bedtime as Number) >= 9414 && (p.bedtime as Number) <= 9416);
    Test.assertEqual(p.bbAtBed, 46);
    Test.assertEqual(p.alarm, 8 * 3600);
    Test.assertEqual(p.bb, 54);
    return true;
}

(:test)
function computeNow(logger as Logger) as Boolean {
    var p = BedtimeCalc.compute(20, 100, 0, 8 * 3600, 10.0, 3.0);
    Test.assertEqual(p.state, BedtimeCalc.STATE_NOW);
    Test.assertEqual(p.bedtime, 0);
    Test.assertEqual(p.reachable, 100);
    Test.assertEqual(p.bbAtBed, 20);
    return true;
}

(:test)
function computeNowWithinWindow(logger as Logger) as Boolean {
    // x = (-46 + 47) / 13 h = 277 s -> inside the 10 min "go now" window
    var p = BedtimeCalc.compute(54, 100, 0, (4.7 * 3600).toNumber(), 10.0, 3.0);
    Test.assertEqual(p.state, BedtimeCalc.STATE_NOW);
    return true;
}

(:test)
function computeLate(logger as Logger) as Boolean {
    var p = BedtimeCalc.compute(10, 100, 0, 5 * 3600, 10.0, 3.0);
    Test.assertEqual(p.state, BedtimeCalc.STATE_LATE);
    Test.assertEqual(p.reachable, 60);
    Test.assertEqual(p.bedtime, 0);
    return true;
}

(:test)
function computeCharged(logger as Logger) as Boolean {
    // BB above the target during the day: still suggest a bedtime
    var p = BedtimeCalc.compute(96, 90, 0, 20 * 3600, 10.0, 3.0);
    Test.assertEqual(p.state, BedtimeCalc.STATE_CHARGED);
    Test.assert(p.bedtime != null);
    return true;
}

(:test)
function computeChargedNoSleepNeeded(logger as Logger) as Boolean {
    var p = BedtimeCalc.compute(100, 100, 0, 2 * 3600, 10.0, 0.0);
    Test.assertEqual(p.state, BedtimeCalc.STATE_CHARGED);
    Test.assert(p.bedtime == null);
    return true;
}

(:test)
function computeNoBb(logger as Logger) as Boolean {
    var p = BedtimeCalc.compute(null, 100, 0, 8 * 3600, 10.0, 3.0);
    Test.assertEqual(p.state, BedtimeCalc.STATE_NO_DATA);
    return true;
}

(:test)
function computeZeroRate(logger as Logger) as Boolean {
    Test.assertEqual(BedtimeCalc.compute(50, 100, 0, 8 * 3600, 0.0, 3.0).state, BedtimeCalc.STATE_NO_DATA);
    Test.assertEqual(BedtimeCalc.compute(50, 100, 0, 8 * 3600, -1.0, 1.0).state, BedtimeCalc.STATE_NO_DATA);
    Test.assertEqual(BedtimeCalc.compute(50, 100, 0, 8 * 3600, 5.0, -1.0).state, BedtimeCalc.STATE_NO_DATA);
    return true;
}
