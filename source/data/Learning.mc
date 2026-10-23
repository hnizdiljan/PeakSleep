import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

// Storage-backed learning of recharge and evening drain rates (foreground only).
module Learning {

    const KEY_NIGHTS = "nights";
    const KEY_LAST_WINDOW = "lastWin";
    // Read by the glance through PlanBuilder.
    const KEY_RATE = "lr";
    const KEY_DRAIN = "ld";
    const KEY_COUNT = "nc";

    function recordSample(now as Number) as Void {
        var buf = Application.Storage.getValue(SampleStore.KEY) as Array<Number>?;
        Application.Storage.setValue(SampleStore.KEY, SampleBuffer.append(buf, now,
            BodyBatteryReader.read(), SampleBuffer.MAX_PAIRS, SampleBuffer.MIN_GAP));
    }

    // Processes sleep windows with samples not seen yet: the current one (up to
    // now, so last night shows up right after waking) and the one before it
    // (the 48 h sample buffer still covers it), oldest first.
    function update(now as Number) as Void {
        var ws = TimeUtil.learningWindows(Time.today().value(), now, Settings.sleepSecOfDay(),
                                          Settings.wakeSecOfDay());
        var todo = LearningMath.windowsToProcess(Application.Storage.getValue(KEY_LAST_WINDOW), ws[0], ws[1]);
        if (todo.size() == 0) {
            return;
        }
        var buf = Application.Storage.getValue(SampleStore.KEY) as Array<Number>?;
        var stored = storedNights();
        for (var i = 0; i < todo.size(); i++) {
            var win = todo[i] as Array<Number>;
            var night = buf == null ? null : NightDetector.detect(buf, win[0], win[1]);
            stored = LearningMath.addNight(stored, night);
        }
        save(stored);
        Application.Storage.setValue(KEY_LAST_WINDOW, (todo[todo.size() - 1] as Array<Number>)[1]);
    }

    function nights() as Array<Night> {
        var stored = storedNights();
        var out = [] as Array<Night>;
        for (var i = 0; i < stored.size(); i++) {
            out.add(Night.fromArray(stored[i]));
        }
        return out;
    }

    function reset() as Void {
        Application.Storage.deleteValue(SampleStore.KEY);
        Application.Storage.deleteValue(KEY_LAST_WINDOW);
        save([] as Array<Array>);
    }

    function storedNights() as Array<Array> {
        var v = Application.Storage.getValue(KEY_NIGHTS);
        return v instanceof Array ? v as Array<Array> : [] as Array<Array>;
    }

    function save(stored as Array<Array>) as Void {
        var s = LearningMath.summarize(stored);
        Application.Storage.setValue(KEY_NIGHTS, stored);
        Application.Storage.setValue(KEY_RATE, s[0]);
        Application.Storage.setValue(KEY_DRAIN, s[1]);
        Application.Storage.setValue(KEY_COUNT, s[2]);
    }
}
