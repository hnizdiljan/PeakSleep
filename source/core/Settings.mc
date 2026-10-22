import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.UserProfile;

// User settings (Garmin Connect app or on-watch menu) with safe defaults.
(:glance)
module Settings {

    // Where the recharge rate comes from.
    const RATE_AUTO = 0;
    const RATE_LEARNING = 1;
    const RATE_MANUAL = 2;

    const DEFAULT_DRAIN = 3.0;
    const MIN_NIGHTS = 3;

    const KEY_TARGET = "targetBB";
    const KEY_RATE_MODE = "rateMode";
    const KEY_RATE = "baseRechargeRate";
    const KEY_WAKE_SOURCE = "wakeSource";
    const KEY_WAKE_HOUR = "wakeUpHour";
    const KEY_WAKE_MINUTE = "wakeUpMinute";

    const DEFAULT_WAKE_HOUR = 7;
    const DEFAULT_WAKE_MINUTE = 0;

    // Any numeric value clamped to [min, max]; anything else gives `def`.
    function numOr(v, def as Number, min as Number, max as Number) as Number {
        var n = def;
        if (v instanceof Number) {
            n = v;
        } else if (v instanceof Float || v instanceof Double || v instanceof Long) {
            n = v.toNumber();
        }
        if (n < min) {
            return min;
        }
        return n > max ? max : n;
    }

    function prop(key as String, def as Number, min as Number, max as Number) as Number {
        var v = null;
        try {
            v = Application.Properties.getValue(key);
        } catch (e) {
            v = null;
        }
        return numOr(v, def, min, max);
    }

    function target() as Number {
        return prop(KEY_TARGET, 100, 50, 100);
    }

    function autoRate() as Boolean {
        return prop(KEY_RATE_MODE, 0, 0, 1) == 0;
    }

    function manualRate() as Float {
        return prop(KEY_RATE, 10, 1, 30).toFloat();
    }

    function useProfileWake() as Boolean {
        return profileWakeEffective(prop(KEY_WAKE_SOURCE, 0, 0, 1), Application.Storage.getValue("ver"),
                                    manualWakeSec());
    }

    function manualWakeSec() as Number {
        return prop(KEY_WAKE_HOUR, DEFAULT_WAKE_HOUR, 0, 23) * 3600
            + prop(KEY_WAKE_MINUTE, DEFAULT_WAKE_MINUTE, 0, 59) * 60;
    }

    // Before migrate() has run (e.g. only the glance was shown after an upgrade),
    // a custom 2.x alarm still wins over the Garmin profile.
    function profileWakeEffective(source as Number, ver, manualWake as Number) as Boolean {
        if (ver == null && manualWake != DEFAULT_WAKE_HOUR * 3600 + DEFAULT_WAKE_MINUTE * 60) {
            return false;
        }
        return source == 0;
    }

    function wakeSecOfDay() as Number {
        if (useProfileWake()) {
            var profile = UserProfile.getProfile();
            if (profile != null && profile.wakeTime != null) {
                return (profile.wakeTime as Time.Duration).value();
            }
        }
        return manualWakeSec();
    }

    function sleepSecOfDay() as Number? {
        var profile = UserProfile.getProfile();
        if (profile != null && profile.sleepTime != null) {
            return (profile.sleepTime as Time.Duration).value();
        }
        return null;
    }

    // [rate, source]: learned rate in auto mode once enough nights exist,
    // otherwise the manual rate.
    function resolveRate(auto as Boolean, learned as Float?, nights as Number, manual as Float) as Array {
        if (auto && learned != null) {
            return [learned, RATE_AUTO];
        }
        return [manual, auto ? RATE_LEARNING : RATE_MANUAL];
    }

    // Foreground only.
    function set(key as String, value as Number) as Void {
        Application.Properties.setValue(key, value);
    }

    // One-time upgrade from 2.x (foreground only): users who set their own alarm
    // keep it instead of silently switching to the Garmin profile.
    function migrate() as Void {
        if (Application.Storage.getValue("ver") != null) {
            return;
        }
        if (manualWakeSec() != DEFAULT_WAKE_HOUR * 3600 + DEFAULT_WAKE_MINUTE * 60) {
            set(KEY_WAKE_SOURCE, 1);
        }
        Application.Storage.setValue("ver", 3);
    }
}
