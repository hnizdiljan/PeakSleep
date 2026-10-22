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

    // Most recent learning window [start, end] that has already ended at `now`.
    function sleepWindow(todayMidnight as Number, now as Number, sleepSecOfDay as Number?,
                         wakeSecOfDay as Number) as [Number, Number] {
        var wakeDay = todayMidnight;
        if (wakeDay + wakeSecOfDay + WINDOW_MARGIN > now) {
            wakeDay -= DAY;
        }
        var end = wakeDay + wakeSecOfDay + WINDOW_MARGIN;
        var start;
        if (sleepSecOfDay == null) {
            start = wakeDay - DAY + FALLBACK_EVENING;
        } else if (sleepSecOfDay > wakeSecOfDay) {
            start = wakeDay - DAY + sleepSecOfDay - WINDOW_MARGIN;
        } else {
            start = wakeDay + sleepSecOfDay - WINDOW_MARGIN;
        }
        return [start, end];
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

    // Czech plural form: 0 = one, 1 = few (2-4), 2 = many.
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
