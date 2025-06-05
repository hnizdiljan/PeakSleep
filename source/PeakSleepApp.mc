import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Define the storage key for the base recharge rate setting
const BASE_RECHARGE_RATE_KEY = "baseRechargeRate";
// Define the default recharge rate if not set by user
const DEFAULT_RECHARGE_RATE = 11.0f;

// Define storage keys for wake-up time settings
const WAKE_UP_HOUR_KEY = "wakeUpHour";
const WAKE_UP_MINUTE_KEY = "wakeUpMinute";

// Define default wake-up time if not set by user
const DEFAULT_WAKE_UP_HOUR = 7;
const DEFAULT_WAKE_UP_MINUTE = 0;

class PeakSleepApp extends Application.AppBase {

    function initialize() {
        System.println("🚀 PeakSleepApp: Initializing application...");
        AppBase.initialize();
        System.println("✅ PeakSleepApp: Application initialized successfully");
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("🌟 PeakSleepApp: Application starting up...");
        if (state != null) {
            System.println("📦 PeakSleepApp: Received state with " + state.size() + " items");
        } else {
            System.println("📦 PeakSleepApp: No state received (fresh start)");
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println("🛑 PeakSleepApp: Application stopping...");
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        System.println("🎯 PeakSleepApp: Creating initial view...");
        try {
            var view = new PeakSleepView();
            System.println("✅ PeakSleepApp: PeakSleepView created successfully");
            
            var delegate = new PeakSleepDelegate(); // Basic delegate
            System.println("✅ PeakSleepApp: PeakSleepDelegate created successfully");
            
            return [ view, delegate ];
        } catch (ex) {
            System.println("❌ PeakSleepApp: Error creating initial view: " + ex.getErrorMessage());
            throw ex;
        }
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

}

function getApp() as PeakSleepApp {
    return Application.getApp() as PeakSleepApp;
} 