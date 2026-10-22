import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

// One row in the glance list: moon icon + "Sleep at 22:40" + a detail line.
(:glance)
class PeakGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var now = Time.now().value();
        var info = PlanBuilder.build(now);
        var p = info.plan;

        var h = dc.getHeight();
        var r = h / 4;
        if (r > 15) {
            r = 15;
        }
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        Theme.drawMoon(dc, r + 1, h / 2, r);

        var x = 2 * r + 10;
        var lead = "";
        var main = Theme.str(Rez.Strings.AppName);
        var mainColor = Graphics.COLOR_WHITE;
        var detail = Theme.str(Rez.Strings.bbUnavailable);
        var detailColor = Theme.C_DIM;

        var bbText = p.bb == null ? "" : Theme.fmt(Rez.Strings.bbValue, [p.bb]);
        if (p.state == BedtimeCalc.STATE_PLAN) {
            var bed = p.bedtime as Number;
            lead = Theme.sleepAtPrefix(bed) + " ";
            main = Theme.hm(bed);
            mainColor = Theme.C_YELLOW;
            if (info.rateSource == Settings.RATE_LEARNING) {
                detail = Theme.fmt(Rez.Strings.learning, [info.nights]);
            } else {
                detail = Theme.fmt(Rez.Strings.inDuration, [TimeUtil.formatDuration(bed - now)]) + " · " + bbText;
            }
        } else if (p.state == BedtimeCalc.STATE_NOW) {
            main = Theme.str(Rez.Strings.goToSleepNow);
            mainColor = Theme.C_BLUE;
            detail = Theme.fmt(Rez.Strings.targetBy, [info.target, Theme.hm(p.alarm)]) + " · " + bbText;
        } else if (p.state == BedtimeCalc.STATE_LATE) {
            main = Theme.str(Rez.Strings.sleepNow);
            detail = Theme.fmt(Rez.Strings.onlyReach, [p.reachable]);
            detailColor = Theme.C_RED;
        } else if (p.state == BedtimeCalc.STATE_CHARGED) {
            main = bbText;
            mainColor = Theme.C_GREEN;
            detail = p.bedtime == null
                ? Theme.str(Rez.Strings.charged)
                : Theme.fmt(Rez.Strings.tonightAround, [Theme.hm(p.bedtime as Number)]);
        }

        var mainFont = Graphics.FONT_TINY;
        var detailFont = Graphics.FONT_XTINY;
        var mainH = dc.getFontHeight(mainFont);
        var detailH = dc.getFontHeight(detailFont);
        var top = (h - mainH - detailH) / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, top, mainFont, lead, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(mainColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + dc.getTextWidthInPixels(lead, mainFont), top, mainFont, main, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(detailColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, top + mainH, detailFont, detail, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
