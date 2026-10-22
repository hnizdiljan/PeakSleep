import Toybox.Lang;

// Pure bookkeeping for learned nights (stored as Night.toArray() rows).
module LearningMath {

    const MAX_NIGHTS = 7;

    // Appends a valid night, keeping only the newest MAX_NIGHTS.
    function addNight(stored as Array<Array>, n as Night?) as Array<Array> {
        if (n == null || !NightDetector.isValid(n)) {
            return stored;
        }
        stored.add(n.toArray());
        if (stored.size() > MAX_NIGHTS) {
            stored = stored.slice(stored.size() - MAX_NIGHTS, null);
        }
        return stored;
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
