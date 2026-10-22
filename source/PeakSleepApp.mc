import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Legacy constants used by the 2.x views (removed in task 7).
const BASE_RECHARGE_RATE_KEY = "baseRechargeRate";
const DEFAULT_RECHARGE_RATE = 10.0f;
const WAKE_UP_HOUR_KEY = "wakeUpHour";
const WAKE_UP_MINUTE_KEY = "wakeUpMinute";
const DEFAULT_WAKE_UP_HOUR = 7;
const DEFAULT_WAKE_UP_MINUTE = 0;

(:background, :glance)
class PeakSleepApp extends Application.AppBase {

    // Body Battery sampling interval for learning.
    const SAMPLE_INTERVAL = 1800;

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        prepareForeground();
        return [new PeakSleepView(), new PeakSleepDelegate()];
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return [new SampleService()];
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    // Upgrade settings, make sure background sampling runs and learn from
    // the last night.
    function prepareForeground() as Void {
        try {
            Settings.migrate();
        } catch (e) {
        }
        ensureBackground();
        var now = Time.now().value();
        try {
            Learning.recordSample(now);
            Learning.update(now);
        } catch (e) {
        }
    }

    function ensureBackground() as Void {
        if (!(Toybox has :Background)) {
            return;
        }
        try {
            if (Background.getTemporalEventRegisteredTime() == null) {
                Background.registerForTemporalEvent(new Time.Duration(SAMPLE_INTERVAL));
            }
        } catch (e) {
        }
    }
}

function getApp() as PeakSleepApp {
    return Application.getApp() as PeakSleepApp;
}
