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
