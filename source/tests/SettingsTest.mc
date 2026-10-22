import Toybox.Lang;
import Toybox.Test;

(:test)
function numOrHandlesNullAndFloat(logger as Logger) as Boolean {
    Test.assertEqual(Settings.numOr(null, 10, 1, 30), 10);
    Test.assertEqual(Settings.numOr(11.7, 10, 1, 30), 11);
    Test.assertEqual(Settings.numOr(500, 10, 1, 30), 30);
    Test.assertEqual(Settings.numOr(-4, 10, 1, 30), 1);
    Test.assertEqual(Settings.numOr("x", 10, 1, 30), 10);
    Test.assertEqual(Settings.numOr(12l, 10, 1, 30), 12);
    return true;
}

(:test)
function resolveRateCases(logger as Logger) as Boolean {
    var r = Settings.resolveRate(true, 8.6, 5, 10.0);
    Test.assertEqual(r[0], 8.6);
    Test.assertEqual(r[1], Settings.RATE_AUTO);

    r = Settings.resolveRate(true, null, 2, 10.0);
    Test.assertEqual(r[0], 10.0);
    Test.assertEqual(r[1], Settings.RATE_LEARNING);

    r = Settings.resolveRate(false, 8.6, 5, 12.0);
    Test.assertEqual(r[0], 12.0);
    Test.assertEqual(r[1], Settings.RATE_MANUAL);
    return true;
}

(:test)
function profileWakeBeforeMigration(logger as Logger) as Boolean {
    // 2.x user with a 05:30 alarm, not yet migrated: keep the manual alarm
    Test.assert(!Settings.profileWakeEffective(0, null, 5 * 3600 + 1800));
    // default alarm before migration: profile
    Test.assert(Settings.profileWakeEffective(0, null, 7 * 3600));
    // migrated: the property decides
    Test.assert(Settings.profileWakeEffective(0, 3, 5 * 3600 + 1800));
    Test.assert(!Settings.profileWakeEffective(1, 3, 7 * 3600));
    return true;
}
