import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class PeakSleepDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle back button press to exit the widget
    function onBack() as Boolean {
        System.println("onBack called in PeakSleepDelegate");
        // If we are on the main view (PeakSleepView), exit the app.
        // If we are on a sub-view (like BedtimeAdvisorView), this onBack will be for that view.
        // This specific onBack is for PeakSleepView, so exiting is correct.
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    // Handle menu button press to navigate to Bedtime Advisor View
    function onMenu() as Boolean {
        System.println("onMenu called in PeakSleepDelegate");
        WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_UP);
        return true;
    } 

    // Add other input handling if needed (taps, swipes etc.)
    // function onSelect() as Boolean {
    //     // Example: Navigate on select/enter press
    //     WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_UP);
    //     return true;
    // }

} 