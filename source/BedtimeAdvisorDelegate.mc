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

    // You can add other input handling here if needed (e.g., onSelect, onMenu)

} 