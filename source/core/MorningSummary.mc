import Toybox.Lang;

// Morning summary of last night, shown after waking up.
(:glance)
module MorningSummary {

    // Steps since midnight that confirm you are up.
    const WAKE_STEPS = 100;
    // The summary stays at least this long after waking (for late risers).
    const SHOW_AFTER_WAKE = 7200;

    // [BB at wake, seconds you fell asleep too late for the target (0 = on time),
    //  nights in a row below target, nights in a row at target] or null when the
    // night has not ended yet or the morning is over.
    // The night has ended when Body Battery stopped rising (a sample after the
    // peak exists) and you have walked; `noon` is the end of the morning.
    function summarize(buf as Array<Number>, ws as Number, we as Number, now as Number, steps as Number,
                       target as Number, stored as Array<Array>, noon as Number) as Array? {
        var n = NightDetector.detect(buf, ws, we);
        if (n == null || !NightDetector.isValid(n) || steps < WAKE_STEPS) {
            return null;
        }
        var end = n.wakeT + SHOW_AFTER_WAKE > noon ? n.wakeT + SHOW_AFTER_WAKE : noon;
        if (now >= end || !hasSampleAfter(buf, n.wakeT, we)) {
            return null;
        }
        var late = 0;
        if (n.wakeBB < target) {
            late = ((target - n.wakeBB) / n.rate() * 3600).toNumber();
        }
        // Earlier nights; the widget may already have stored tonight.
        var reached = [] as Array<Boolean>;
        for (var i = 0; i < stored.size(); i++) {
            var s = Night.fromArray(stored[i]);
            if (s.onsetT >= n.wakeT || s.wakeT <= n.onsetT) {
                reached.add(s.wakeBB >= target);
            }
        }
        reached.add(n.wakeBB >= target);
        var below = 0;
        var at = 0;
        for (var j = reached.size() - 1; j >= 0; j--) {
            if (reached[j] && below == 0) {
                at++;
            } else if (!reached[j] && at == 0) {
                below++;
            } else {
                break;
            }
        }
        return [n.wakeBB, late, below, at];
    }

    function hasSampleAfter(buf as Array<Number>, t as Number, we as Number) as Boolean {
        for (var i = 0; i + 1 < buf.size(); i += 2) {
            if (buf[i] > t && buf[i] <= we) {
                return true;
            }
        }
        return false;
    }
}
