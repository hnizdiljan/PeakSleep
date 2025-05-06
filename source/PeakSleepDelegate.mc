import Toybox.Lang;
import Toybox.WatchUi;

class PeakSleepDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle back button press to exit the widget
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    // Handle menu button press (could be used for on-device settings later)
    function onMenu() as Boolean {
        // For now, do nothing or provide a simple message
        // WatchUi.pushView(new Rez.Menus.MainMenu(), new PeakSleepMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    } 

    // Add other input handling if needed (taps, swipes etc.)

} 