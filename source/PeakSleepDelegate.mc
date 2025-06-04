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

    // Handle UP button press to navigate to Bedtime Advisor View
    function onNextPage() as Boolean {
        System.println("onNextPage called in PeakSleepDelegate - navigating to Bedtime Advisor");
        WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    // Handle DOWN button press to navigate to Bedtime Advisor View (alternative)
    function onPreviousPage() as Boolean {
        System.println("onPreviousPage called in PeakSleepDelegate - navigating to Bedtime Advisor");
        WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    // Handle swipe gestures for touchscreen devices
    function onSwipe(swipeEvent as SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        System.println("onSwipe called in PeakSleepDelegate - direction: " + direction);
        
        // Swipe UP or RIGHT to navigate forward to Bedtime Advisor
        if (direction == WatchUi.SWIPE_UP || direction == WatchUi.SWIPE_RIGHT) {
            System.println("Swipe UP/RIGHT detected - navigating to Bedtime Advisor");
            WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_UP);
            return true;
        }
        // Swipe LEFT to also navigate to Bedtime Advisor (alternative)
        else if (direction == WatchUi.SWIPE_LEFT) {
            System.println("Swipe LEFT detected - navigating to Bedtime Advisor");
            WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_LEFT);
            return true;
        }
        
        return false; // Let other handlers process unrecognized swipes (like DOWN)
    }

    // Keep menu functionality as backup option
    function onMenu() as Boolean {
        System.println("onMenu called in PeakSleepDelegate");
        WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_UP);
        return true;
    } 

    // Optional: Add select button for navigation as well
    function onSelect() as Boolean {
        System.println("onSelect called in PeakSleepDelegate - navigating to Bedtime Advisor");
        WatchUi.pushView(new BedtimeAdvisorView(), new BedtimeAdvisorDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

} 