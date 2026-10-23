import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;

// Reads what the morning summary needs. Read-only, so it is safe in the glance.
(:glance)
module MorningData {

    // A bedtime this close to the needed one counts as on time.
    const ON_TIME = 900;
    // How far below the target still shows yellow instead of red.
    const NEAR_TARGET = 15;

    // MorningSummary.summarize result for the current morning, or null.
    function current(now as Number) as Array? {
        try {
            var buf = Application.Storage.getValue(SampleStore.KEY);
            if (!(buf instanceof Array)) {
                return null;
            }
            var today = Time.today().value();
            var win = TimeUtil.learningWindows(today, now, Settings.sleepSecOfDay(),
                                               Settings.wakeSecOfDay())[1] as Array<Number>;
            var info = ActivityMonitor.getInfo();
            var steps = info.steps == null ? 0 : info.steps as Number;
            var stored = Application.Storage.getValue("nights");
            return MorningSummary.summarize(buf as Array<Number>, win[0], win[1], now, steps, Settings.target(),
                                            stored instanceof Array ? stored as Array<Array> : [] as Array<Array>,
                                            today + 12 * TimeUtil.HOUR);
        } catch (e) {
            return null;
        }
    }

    function color(wakeBB as Number, target as Number) as Number {
        if (wakeBB >= target) {
            return Theme.C_GREEN;
        }
        return wakeBB >= target - NEAR_TARGET ? Theme.C_YELLOW : Theme.C_RED;
    }

    // "bedtime on time" / "bedtime 35 min late"
    function lateText(late as Number) as String {
        if (late <= ON_TIME) {
            return Theme.str(Rez.Strings.bedOnTime);
        }
        return Theme.fmt(Rez.Strings.bedLate, [TimeUtil.formatDuration(late)]);
    }

    // "3× below" / "3× on target" for narrow glances; empty for a single night.
    function streakTiny(below as Number, at as Number) as String {
        if (below >= 2) {
            return Theme.fmt(Rez.Strings.streakBelowTiny, [below]);
        }
        if (at >= 2) {
            return Theme.fmt(Rez.Strings.streakAtTiny, [at]);
        }
        return "";
    }

    // "3 nights below target" / "5 nights at target"; empty for a single night.
    function streakText(below as Number, at as Number) as String {
        if (below >= 2) {
            return Theme.fmt(TimeUtil.pluralIndex(below) == 1 ? Rez.Strings.streakBelowFew : Rez.Strings.streakBelowMany,
                             [below]);
        }
        if (at >= 2) {
            return Theme.fmt(TimeUtil.pluralIndex(at) == 1 ? Rez.Strings.streakAtFew : Rez.Strings.streakAtMany, [at]);
        }
        return "";
    }
}
