import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

// Everything a screen needs to show the current recommendation.
(:glance)
class PlanInfo {
    public var plan as BedtimePlan;
    public var rate as Float;
    public var rateSource as Number;
    public var drain as Float;
    public var nights as Number;
    public var target as Number;

    function initialize(plan as BedtimePlan, rate as Float, rateSource as Number, drain as Float,
                        nights as Number, target as Number) {
        self.plan = plan;
        self.rate = rate;
        self.rateSource = rateSource;
        self.drain = drain;
        self.nights = nights;
        self.target = target;
    }
}

// Combines current Body Battery, settings and learned values. Read-only, so it
// is safe in the glance.
(:glance)
module PlanBuilder {

    function build(now as Number) as PlanInfo {
        var learned = Application.Storage.getValue("lr");
        var drainV = Application.Storage.getValue("ld");
        var count = Settings.numOr(Application.Storage.getValue("nc"), 0, 0, 99);
        var r = Settings.resolveRate(Settings.autoRate(),
                                     learned instanceof Float ? learned : null,
                                     count, Settings.manualRate());
        var rate = r[0] as Float;
        var drain = drainV instanceof Float ? drainV : Settings.DEFAULT_DRAIN;
        var target = Settings.target();
        var alarm = TimeUtil.nextAlarm(Time.today().value(), now, Settings.wakeSecOfDay());
        var plan = BedtimeCalc.compute(BodyBatteryReader.read(), target, now, alarm, rate, drain);
        return new PlanInfo(plan, rate, r[1] as Number, drain, count, target);
    }
}
