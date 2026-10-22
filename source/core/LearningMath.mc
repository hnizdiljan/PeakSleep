import Toybox.Lang;

// Pure bookkeeping for learned nights (stored as Night.toArray() rows).
module LearningMath {

    const MAX_NIGHTS = 7;

    // Appends a valid night, keeping only the newest MAX_NIGHTS.
    function addNight(stored as Array<Array>, n as Night?) as Array<Array> {
        if (n == null || !NightDetector.isValid(n)) {
            return stored;
        }
        // The same night can be found again (e.g. after the alarm time changed).
        if (stored.size() > 0 && n.wakeT <= Night.fromArray(stored[stored.size() - 1]).wakeT) {
            return stored;
        }
        stored.add(n.toArray());
        if (stored.size() > MAX_NIGHTS) {
            stored = stored.slice(stored.size() - MAX_NIGHTS, null);
        }
        return stored;
    }

    // Learning windows not processed yet, oldest first. `lastDone` is the end of
    // the newest processed window (null when none).
    function windowsToProcess(lastDone, older as Array, latest as Array) as Array {
        var out = [];
        var done = lastDone instanceof Number ? lastDone : null;
        if (done == null || (older[1] as Number) > done) {
            out.add(older);
        }
        if (done == null || (latest[1] as Number) > done) {
            out.add(latest);
        }
        return out;
    }

    // [learned rate or null (fewer than MIN_NIGHTS), learned drain or null, night count]
    function summarize(stored as Array<Array>) as Array {
        var rates = [] as Array<Float>;
        var drains = [] as Array<Float>;
        for (var i = 0; i < stored.size(); i++) {
            var n = Night.fromArray(stored[i]);
            rates.add(n.rate());
            if (n.drain != null) {
                drains.add(n.drain as Float);
            }
        }
        var rate = rates.size() >= Settings.MIN_NIGHTS ? NightDetector.median(rates) : null;
        return [rate, NightDetector.median(drains), rates.size()];
    }
}
