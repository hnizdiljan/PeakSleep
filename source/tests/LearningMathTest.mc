import Toybox.Lang;
import Toybox.Test;

(:test)
function addNightKeepsOnlyValidAndLastSeven(logger as Logger) as Boolean {
    var stored = [] as Array<Array>;
    // invalid (1 h) night is ignored
    stored = LearningMath.addNight(stored, new Night(0, 50, 3600, 60, null));
    Test.assertEqual(stored.size(), 0);
    stored = LearningMath.addNight(stored, null);
    Test.assertEqual(stored.size(), 0);
    for (var i = 0; i < 9; i++) {
        stored = LearningMath.addNight(stored, new Night(i * 86400, 40, i * 86400 + 8 * 3600, 40 + 8 * (i + 2), 2.0));
    }
    Test.assertEqual(stored.size(), LearningMath.MAX_NIGHTS);
    // oldest two dropped: first kept night is i = 2
    Test.assertEqual(Night.fromArray(stored[0]).onsetT, 2 * 86400);
    return true;
}

(:test)
function summarizeNeedsThreeNights(logger as Logger) as Boolean {
    var stored = [
        new Night(0, 40, 8 * 3600, 104 - 4, 2.0).toArray(),
        new Night(0, 40, 8 * 3600, 88, null).toArray()
    ] as Array<Array>;
    var s = LearningMath.summarize(stored);
    Test.assert(s[0] == null);
    Test.assertEqual(s[1], 2.0);
    Test.assertEqual(s[2], 2);

    stored.add(new Night(0, 40, 8 * 3600, 96, 4.0).toArray());
    s = LearningMath.summarize(stored);
    // rates 7.5, 6.0, 7.0 -> median 7.0; drains 2.0, 4.0 -> 3.0
    Test.assertEqual(s[0], 7.0);
    Test.assertEqual(s[1], 3.0);
    Test.assertEqual(s[2], 3);
    return true;
}

(:test)
function summarizeEmpty(logger as Logger) as Boolean {
    var s = LearningMath.summarize([] as Array<Array>);
    Test.assert(s[0] == null);
    Test.assert(s[1] == null);
    Test.assertEqual(s[2], 0);
    return true;
}

(:test)
function addNightRejectsSameOrOlderNight(logger as Logger) as Boolean {
    var stored = [] as Array<Array>;
    stored = LearningMath.addNight(stored, new Night(0, 40, 8 * 3600, 96, 2.0));
    // the same night detected again (e.g. after the alarm time changed)
    stored = LearningMath.addNight(stored, new Night(0, 40, 8 * 3600, 96, 2.0));
    Test.assertEqual(stored.size(), 1);
    // an older night found later is ignored too
    stored = LearningMath.addNight(stored, new Night(-86400, 40, -86400 + 8 * 3600, 96, 2.0));
    Test.assertEqual(stored.size(), 1);
    stored = LearningMath.addNight(stored, new Night(86400, 40, 86400 + 8 * 3600, 96, 2.0));
    Test.assertEqual(stored.size(), 2);
    return true;
}

(:test)
function windowsToProcessSkipsDone(logger as Logger) as Boolean {
    var older = [100, 200];
    var latest = [1100, 1200];
    // nothing processed yet: both, oldest first
    var w = LearningMath.windowsToProcess(null, older, latest);
    Test.assertEqual(w.size(), 2);
    Test.assertEqual((w[0] as Array)[1], 200);
    // older already processed
    w = LearningMath.windowsToProcess(200, older, latest);
    Test.assertEqual(w.size(), 1);
    Test.assertEqual((w[0] as Array)[1], 1200);
    // everything processed
    Test.assertEqual(LearningMath.windowsToProcess(1200, older, latest).size(), 0);
    return true;
}
