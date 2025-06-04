import Toybox.Lang;
import Toybox.WatchUi;

class BedtimeAdvisorDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle back behavior
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handle UP button press to go back to main view
    function onNextPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handle DOWN button press to go back to main view
    function onPreviousPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handle swipe gestures for touchscreen devices
    function onSwipe(swipeEvent as SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        System.println("onSwipe called in BedtimeAdvisorDelegate - direction: " + direction);
        
        // Swipe DOWN or LEFT to go back to main view
        if (direction == WatchUi.SWIPE_DOWN || direction == WatchUi.SWIPE_LEFT) {
            System.println("Swipe DOWN/LEFT detected - returning to main view");
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        // Swipe RIGHT to also go back to main view (alternative)
        else if (direction == WatchUi.SWIPE_RIGHT) {
            System.println("Swipe RIGHT detected - returning to main view");
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        
        return false; // Let other handlers process unrecognized swipes (like UP)
    }

    // Handle select button press to go back to main view
    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // Keep menu functionality as backup
    function onMenu() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // You can add other input handling here if needed (e.g., onSelect, onMenu)

} 