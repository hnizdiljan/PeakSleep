import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Shared colors, text and drawing helpers for glance and pages.
(:glance)
module Theme {

    const C_YELLOW = 0xF5C400;
    const C_YELLOW_DARK = 0x6B5600;
    const C_BLUE = 0x7FB2FF;
    const C_RED = 0xFF5A4F;
    const C_GREEN = 0x4CD964;
    const C_DIM = 0xAAAAAA;
    const C_TRACK = 0x222222;
    const C_MOON_BG = 0x1D2B5C;
    const C_MOON = 0x9DB4FF;

    function stateColor(state as Number) as Number {
        if (state == BedtimeCalc.STATE_PLAN) {
            return C_YELLOW;
        }
        if (state == BedtimeCalc.STATE_NOW) {
            return C_BLUE;
        }
        if (state == BedtimeCalc.STATE_LATE) {
            return C_RED;
        }
        if (state == BedtimeCalc.STATE_CHARGED) {
            return C_GREEN;
        }
        return Graphics.COLOR_WHITE;
    }

    // Darker shade of the state color for the predicted evening drain on the ring.
    function darkColor(state as Number) as Number {
        if (state == BedtimeCalc.STATE_CHARGED) {
            return 0x1F5F2C;
        }
        return state == BedtimeCalc.STATE_PLAN ? C_YELLOW_DARK : 0x444444;
    }

    function str(id as ResourceId) as String {
        return WatchUi.loadResource(id) as String;
    }

    function fmt(id as ResourceId, args as Array) as String {
        return Lang.format(str(id), args);
    }

    // Clock time honoring the device's 12/24 h setting, e.g. "22:40" or "6:30".
    function hm(epoch as Number) as String {
        var info = Gregorian.info(new Time.Moment(epoch), Time.FORMAT_SHORT);
        var hour = info.hour as Number;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12 == 0 ? 12 : hour % 12;
        }
        return hour.format("%d") + ":" + (info.min as Number).format("%02d");
    }

    function hourOf(epoch as Number) as Number {
        return Gregorian.info(new Time.Moment(epoch), Time.FORMAT_SHORT).hour as Number;
    }

    // "Sleep at" / "Spát v" / "Spát ve" depending on the hour.
    function sleepAtPrefix(epoch as Number) as String {
        return str(TimeUtil.czechVe(hourOf(epoch)) ? Rez.Strings.sleepAtVe : Rez.Strings.sleepAtV);
    }

    // Crescent moon: filled disc with a background-colored disc cut out.
    function drawMoon(dc as Dc, x as Number, y as Number, r as Number) as Void {
        dc.setColor(C_MOON_BG, C_MOON_BG);
        dc.fillCircle(x, y, r);
        var m = (r * 0.55).toNumber();
        dc.setColor(C_MOON, C_MOON);
        dc.fillCircle(x, y, m);
        dc.setColor(C_MOON_BG, C_MOON_BG);
        dc.fillCircle(x + m / 2, y - m / 3, m);
    }
}
