import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class HistoricalStatsDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        // Vrať se zpět na hlavní pohled
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onBack() as Boolean {
        // Vrať se zpět na hlavní pohled
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSelect() as Boolean {
        // Vymaž historická data pro testování (dlouhé stisknutí)
        System.println("Clearing historical data for testing");
        SleepLogic.clearHistoricalData();
        WatchUi.requestUpdate();
        return true;
    }
} 