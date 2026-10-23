import Toybox.Lang;
import Toybox.Test;

(:test)
function nextAlarmEvening(logger as Logger) as Boolean {
    var h = TimeUtil.HOUR;
    Test.assertEqual(TimeUtil.nextAlarm(0, 22 * h, (6.5 * h).toNumber()), TimeUtil.DAY + (6.5 * h).toNumber());
    return true;
}

(:test)
function nextAlarmAfterMidnight(logger as Logger) as Boolean {
    var h = TimeUtil.HOUR;
    Test.assertEqual(TimeUtil.nextAlarm(0, (1.5 * h).toNumber(), (6.5 * h).toNumber()), (6.5 * h).toNumber());
    return true;
}

(:test)
function nextAlarmExactlyAtAlarm(logger as Logger) as Boolean {
    var h = TimeUtil.HOUR;
    var wake = (6.5 * h).toNumber();
    Test.assertEqual(TimeUtil.nextAlarm(0, wake, wake), TimeUtil.DAY + wake);
    return true;
}

(:test)
function sleepWindowMorning(logger as Logger) as Boolean {
    var d = TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var w = TimeUtil.sleepWindow(10 * d, 10 * d + 12 * h, 23 * h, 7 * h);
    Test.assertEqual(w[0], 10 * d - 4 * h);
    Test.assertEqual(w[1], 10 * d + 10 * h);
    return true;
}

(:test)
function sleepWindowRightAfterWake(logger as Logger) as Boolean {
    var d = TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    // 08:00, woke at 07:00: last night's window is the current one, not the night before
    var w = TimeUtil.sleepWindow(10 * d, 10 * d + 8 * h, 23 * h, 7 * h);
    Test.assertEqual(w[0], 10 * d - 4 * h);
    Test.assertEqual(w[1], 10 * d + 10 * h);
    return true;
}

(:test)
function sleepWindowSwitchesAtWindowStart(logger as Logger) as Boolean {
    var d = TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    // 19:00: tonight's window (from 20:00) has not started yet
    var w = TimeUtil.sleepWindow(10 * d, 10 * d + 19 * h, 23 * h, 7 * h);
    Test.assertEqual(w[0], 10 * d - 4 * h);
    // 21:00: tonight's window is running
    w = TimeUtil.sleepWindow(10 * d, 10 * d + 21 * h, 23 * h, 7 * h);
    Test.assertEqual(w[0], 11 * d - 4 * h);
    Test.assertEqual(w[1], 11 * d + 10 * h);
    return true;
}

(:test)
function learningWindowsClipLatestToNow(logger as Logger) as Boolean {
    var d = TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var ws = TimeUtil.learningWindows(10 * d, 10 * d + 8 * h, 23 * h, 7 * h);
    var older = ws[0] as Array<Number>;
    var latest = ws[1] as Array<Number>;
    Test.assertEqual(older[0], 9 * d - 4 * h);
    Test.assertEqual(older[1], 9 * d + 10 * h);
    Test.assertEqual(latest[0], 10 * d - 4 * h);
    // only samples up to now are available
    Test.assertEqual(latest[1], 10 * d + 8 * h);
    // after the window ends the full window is used
    latest = TimeUtil.learningWindows(10 * d, 10 * d + 12 * h, 23 * h, 7 * h)[1] as Array<Number>;
    Test.assertEqual(latest[1], 10 * d + 10 * h);
    return true;
}

(:test)
function sleepWindowSleepAfterMidnight(logger as Logger) as Boolean {
    var d = TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    // usual sleep at 00:30 belongs to the same calendar day as the wake time
    var w = TimeUtil.sleepWindow(10 * d, 10 * d + 12 * h, (0.5 * h).toNumber(), 7 * h);
    Test.assertEqual(w[0], 10 * d + (0.5 * h).toNumber() - 3 * h);
    Test.assertEqual(w[1], 10 * d + 10 * h);
    return true;
}

(:test)
function sleepWindowNoSleepTime(logger as Logger) as Boolean {
    var d = TimeUtil.DAY;
    var h = TimeUtil.HOUR;
    var w = TimeUtil.sleepWindow(10 * d, 10 * d + 12 * h, null, 7 * h);
    Test.assertEqual(w[0], 10 * d - 6 * h);
    Test.assertEqual(w[1], 10 * d + 10 * h);
    return true;
}

(:test)
function formatDurationCases(logger as Logger) as Boolean {
    Test.assertEqual(TimeUtil.formatDuration(4800), "1 h 20 min");
    Test.assertEqual(TimeUtil.formatDuration(2700), "45 min");
    Test.assertEqual(TimeUtil.formatDuration(0), "0 min");
    Test.assertEqual(TimeUtil.formatDuration(-50), "0 min");
    Test.assertEqual(TimeUtil.formatDuration(3600), "1 h 0 min");
    return true;
}

(:test)
function czechVeCases(logger as Logger) as Boolean {
    var ve = [2, 3, 4, 12, 13, 14, 20, 21, 22, 23];
    for (var hr = 0; hr < 24; hr++) {
        Test.assertEqual(TimeUtil.czechVe(hr), ve.indexOf(hr) >= 0);
    }
    return true;
}

(:test)
function pluralCases(logger as Logger) as Boolean {
    Test.assertEqual(TimeUtil.pluralIndex(1), 0);
    Test.assertEqual(TimeUtil.pluralIndex(3), 1);
    Test.assertEqual(TimeUtil.pluralIndex(5), 2);
    Test.assertEqual(TimeUtil.pluralIndex(0), 2);
    Test.assertEqual(TimeUtil.pluralIndex(11), 2);
    return true;
}
