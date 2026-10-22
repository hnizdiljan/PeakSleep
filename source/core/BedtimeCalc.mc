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
    // Garmin's Body Battery does not drop below about 5.
    const BB_FLOOR = 5;

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
        // Body Battery never drains below the floor: once it gets there, only
        // the time asleep matters.
        var low = bb < BB_FLOOR ? bb : BB_FLOOR;
        var drained = false;
        if (bb - drain * x < low) {
            x = hoursLeft - (target - low) / rate;
            drained = true;
        }
        var nowWindow = NOW_WINDOW / 3600.0;

        if (bb >= target) {
            p.state = STATE_CHARGED;
            p.bbAtBed = drained ? low : Math.round(bb - drain * x).toNumber();
            p.bedtime = (x >= hoursLeft || x <= nowWindow) ? null : now + Math.round(x * 3600).toNumber();
            return p;
        }

        if (x <= nowWindow) {
            var reach = Math.round(bb + rate * hoursLeft).toNumber();
            p.reachable = reach > 100 ? 100 : reach;
            p.bedtime = now;
            p.bbAtBed = bb;
            p.state = (p.reachable as Number) >= target ? STATE_NOW : STATE_LATE;
            return p;
        }

        p.bbAtBed = drained ? low : Math.round(bb - drain * x).toNumber();
        p.state = STATE_PLAN;
        p.bedtime = now + Math.round(x * 3600).toNumber();
        return p;
    }
}
