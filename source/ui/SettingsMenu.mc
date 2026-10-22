import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// On-watch settings: same values as in the Garmin Connect app.
module SettingsMenu {

    function open() as Void {
        var menu = new WatchUi.Menu2({ :title => Theme.str(Rez.Strings.menuTitle) });
        menu.addItem(new WatchUi.MenuItem(Theme.str(Rez.Strings.setTarget), "", :target, null));
        menu.addItem(new WatchUi.MenuItem(Theme.str(Rez.Strings.setRateMode), "", :rateMode, null));
        menu.addItem(new WatchUi.MenuItem(Theme.str(Rez.Strings.setRate), "", :rate, null));
        menu.addItem(new WatchUi.MenuItem(Theme.str(Rez.Strings.setWakeSource), "", :wakeSource, null));
        menu.addItem(new WatchUi.MenuItem(Theme.str(Rez.Strings.menuAlarmTime), "", :alarm, null));
        menu.addItem(new WatchUi.MenuItem(Theme.str(Rez.Strings.menuReset), "", :reset, null));
        var delegate = new SettingsMenuDelegate(menu);
        delegate.refresh();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_LEFT);
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as WatchUi.Menu2;

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    // Current values as sublabels.
    function refresh() as Void {
        setSub(:target, Theme.fmt(Rez.Strings.pctValue, [Settings.target()]));
        setSub(:rateMode, Theme.str(Settings.autoRate() ? Rez.Strings.optAuto : Rez.Strings.optManual));
        setSub(:rate, Settings.manualRate().format("%d") + "/h");
        setSub(:wakeSource, Theme.str(Settings.useProfileWake() ? Rez.Strings.optProfile : Rez.Strings.optManual));
        var wake = Settings.manualWakeSec();
        setSub(:alarm, (wake / 3600).format("%d") + ":" + ((wake % 3600) / 60).format("%02d"));
        WatchUi.requestUpdate();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :target) {
            pushStepper(Rez.Strings.setTarget, Settings.target(), 50, 100, 5, "%d", method(:onTarget));
        } else if (id == :rateMode) {
            Settings.set(Settings.KEY_RATE_MODE, Settings.autoRate() ? 1 : 0);
            refresh();
        } else if (id == :rate) {
            pushStepper(Rez.Strings.setRate, Settings.manualRate().toNumber(), 1, 30, 1, "%d", method(:onRate));
        } else if (id == :wakeSource) {
            Settings.set(Settings.KEY_WAKE_SOURCE, Settings.useProfileWake() ? 1 : 0);
            refresh();
        } else if (id == :alarm) {
            pushStepper(Rez.Strings.setWakeHour, Settings.manualWakeSec() / 3600, 0, 23, 1, "%d", method(:onHour));
        } else if (id == :reset) {
            WatchUi.pushView(new WatchUi.Confirmation(Theme.str(Rez.Strings.menuResetConfirm)),
                             new ResetConfirmDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function onTarget(value as Number) as Void {
        Settings.set(Settings.KEY_TARGET, value);
        refresh();
    }

    function onRate(value as Number) as Void {
        Settings.set(Settings.KEY_RATE, value);
        refresh();
    }

    function onHour(value as Number) as Void {
        Settings.set(Settings.KEY_WAKE_HOUR, value);
        var minute = (Settings.manualWakeSec() % 3600) / 60;
        pushStepper(Rez.Strings.setWakeMinute, minute - minute % 5, 0, 55, 5, "%02d", method(:onMinute));
    }

    function onMinute(value as Number) as Void {
        Settings.set(Settings.KEY_WAKE_MINUTE, value);
        // Setting an alarm time by hand means the user wants it used.
        Settings.set(Settings.KEY_WAKE_SOURCE, 1);
        refresh();
    }

    private function setSub(id as Symbol, text as String) as Void {
        var i = _menu.findItemById(id);
        if (i >= 0) {
            (_menu.getItem(i) as WatchUi.MenuItem).setSubLabel(text);
        }
    }
}

class ResetConfirmDelegate extends WatchUi.ConfirmationDelegate {

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            Learning.reset();
        }
        return true;
    }
}
