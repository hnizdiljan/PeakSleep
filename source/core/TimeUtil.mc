import Toybox.Lang;

// Pure time helpers. All times are epoch seconds (Number); "secOfDay" is
// seconds since local midnight.
(:glance, :background)
module TimeUtil {

    const DAY = 86400;
    const HOUR = 3600;

    // How far the learning window reaches before usual sleep and after usual wake.
    const WINDOW_MARGIN = 10800;
    // Evening start used when the profile has no sleep time.
    const FALLBACK_EVENING = 64800;

    // First occurrence of the wake time strictly after `now`.
    function nextAlarm(todayMidnight as Number, now as Number, wakeSecOfDay as Number) as Number {
        var alarm = todayMidnight + wakeSecOfDay;
        while (alarm <= now) {
            alarm += DAY;
        }
        while (alarm - DAY > now) {
            alarm -= DAY;
        }
        return alarm;
    }

    // Most recent learning window [start, end] that has already started at `now`
    // (it may still be running).
    function sleepWindow(todayMidnight as Number, now as Number, sleepSecOfDay as Number?,
                         wakeSecOfDay as Number) as [Number, Number] {
        var wakeDay = todayMidnight + DAY;
        while (windowStart(wakeDay, sleepSecOfDay, wakeSecOfDay) > now) {
            wakeDay -= DAY;
        }
        return [windowStart(wakeDay, sleepSecOfDay, wakeSecOfDay), wakeDay + wakeSecOfDay + WINDOW_MARGIN];
    }

    // Start of the window of the night that ends on `wakeDay` (local midnight).
    function windowStart(wakeDay as Number, sleepSecOfDay as Number?, wakeSecOfDay as Number) as Number {
        if (sleepSecOfDay == null) {
            return wakeDay - DAY + FALLBACK_EVENING;
        }
        if (sleepSecOfDay > wakeSecOfDay) {
            return wakeDay - DAY + sleepSecOfDay - WINDOW_MARGIN;
        }
        return wakeDay + sleepSecOfDay - WINDOW_MARGIN;
    }

    // [previous window, current window cut at `now`]. The current night is
    // learned from the samples collected so far and refined on later visits.
    function learningWindows(todayMidnight as Number, now as Number, sleepSecOfDay as Number?,
                             wakeSecOfDay as Number) as [Array<Number>, Array<Number>] {
        var latest = sleepWindow(todayMidnight, now, sleepSecOfDay, wakeSecOfDay);
        var end = latest[1] < now ? latest[1] : now;
        return [[latest[0] - DAY, latest[1] - DAY], [latest[0], end]];
    }

    // "1 h 20 min" / "45 min"; negative durations show as "0 min".
    function formatDuration(sec as Number) as String {
        if (sec < 0) {
            sec = 0;
        }
        var h = sec / HOUR;
        var m = (sec % HOUR) / 60;
        if (h > 0) {
            return h.format("%d") + " h " + m.format("%d") + " min";
        }
        return m.format("%d") + " min";
    }

    // Czech uses "ve" instead of "v" before hours pronounced with a leading
    // consonant cluster (dvě, tři, čtyři, dvanáct, ..., dvacet tři).
    function czechVe(hour as Number) as Boolean {
        return (hour >= 2 && hour <= 4) || (hour >= 12 && hour <= 14) || hour >= 20;
    }

    // Plural form: 0 = one, 1 = few (2-4), 2 = many. Matches Czech; also Polish for the
    // small counts used here (up to 7 nights). Other languages use the same text for few and many.
    function pluralIndex(n as Number) as Number {
        if (n == 1) {
            return 0;
        }
        if (n >= 2 && n <= 4) {
            return 1;
        }
        return 2;
    }
}
