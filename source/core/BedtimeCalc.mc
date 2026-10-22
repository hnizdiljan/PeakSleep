import Toybox.Lang;
import Toybox.Math;

// Result of a bedtime calculation.
(:glance)
class BedtimePlan {
    public var state as Number = BedtimeCalc.STATE_NO_DATA;
    // Recommended time to fall asleep (epoch s); null when no sleep is needed.
    public var bedtime as Number? = null;
    // Predicted Body Battery at bedtime.
    public var bbAtBed as Number? = null;
    // Body Battery reachable by the alarm when sleeping now (NOW / LATE).
    public var reachable as Number? = null;
    public var alarm as Number = 0;
    public var bb as Number? = null;

    function initialize() {
    }
}

(:glance)
module BedtimeCalc {

    const STATE_NO_DATA = 0;
    const STATE_PLAN = 1;
    const STATE_NOW = 2;
    const STATE_LATE = 3;
    const STATE_CHARGED = 4;

    // A bedtime closer than this to now is shown as "go to sleep now".
    const NOW_WINDOW = 600;

    // Finds the time T between now and the alarm at which falling asleep reaches
    // `target` by the alarm, given evening drain `drain` and night recharge
    // `rate` (both BB per hour):  bb - drain*(T-now) + rate*(alarm-T) = target
    function compute(bb as Number?, target as Number, now as Number, alarm as Number,
                     rate as Float, drain as Float) as BedtimePlan {
        var p = new BedtimePlan();
        p.alarm = alarm;
        p.bb = bb;
        if (bb == null || rate <= 0 || drain < 0) {
            return p;
        }

        var hoursLeft = (alarm - now) / 3600.0;
        var x = (bb - target + rate * hoursLeft) / (drain + rate);

        if (x <= NOW_WINDOW / 3600.0) {
            var reach = Math.round(bb + rate * hoursLeft).toNumber();
            p.reachable = reach > 100 ? 100 : reach;
            p.bedtime = now;
            p.bbAtBed = bb;
            p.state = (p.reachable as Number) >= target ? STATE_NOW : STATE_LATE;
            return p;
        }

        p.bbAtBed = Math.round(bb - drain * x).toNumber();
        if (bb >= target) {
            p.state = STATE_CHARGED;
            p.bedtime = x >= hoursLeft ? null : now + Math.round(x * 3600).toNumber();
        } else {
            p.state = STATE_PLAN;
            p.bedtime = now + Math.round(x * 3600).toNumber();
        }
        return p;
    }
}
