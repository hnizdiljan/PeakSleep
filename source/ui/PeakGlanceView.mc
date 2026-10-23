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
        // Used when `detail` (then `detailShort`, `main`) does not fit the glance width.
        var detailShort = "";
        var detailTiny = "";
        var mainShort = "";

        var bbText = p.bb == null ? "" : Theme.fmt(Rez.Strings.bbValue, [p.bb]);
        if (p.state == BedtimeCalc.STATE_PLAN) {
            var bed = p.bedtime as Number;
            lead = Theme.sleepAtPrefix(bed) + " ";
            main = Theme.hm(bed);
            mainColor = Theme.C_YELLOW;
            if (info.rateSource == Settings.RATE_LEARNING) {
                detail = Theme.fmt(Rez.Strings.learning, [info.nights]);
                detailShort = Theme.fmt(Rez.Strings.learningShort, [info.nights]);
            } else {
                detailShort = Theme.fmt(Rez.Strings.inDuration, [TimeUtil.formatDuration(bed - now)]);
                detail = detailShort + " · " + bbText;
            }
        } else if (p.state == BedtimeCalc.STATE_NOW) {
            main = Theme.str(Rez.Strings.goToSleepNow);
            mainColor = Theme.C_BLUE;
            detailShort = Theme.fmt(Rez.Strings.targetBy, [info.target, Theme.hm(p.alarm)]);
            detail = detailShort + " · " + bbText;
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
        // After waking up: how last night went instead of tonight's plan.
        var morning = MorningData.current(now);
        if (morning != null) {
            var wakeBB = morning[0] as Number;
            lead = "";
            main = Theme.fmt(Rez.Strings.morningCharged, [wakeBB]);
            mainShort = Theme.fmt(Rez.Strings.bbValue, [wakeBB]);
            mainColor = MorningData.color(wakeBB, info.target);
            var late = MorningData.lateText(morning[1] as Number);
            var streak = MorningData.streakText(morning[2] as Number, morning[3] as Number);
            detail = streak.equals("") ? late : late + " · " + streak;
            detailShort = streak.equals("") ? late : streak;
            detailTiny = MorningData.streakTiny(morning[2] as Number, morning[3] as Number);
            detailColor = Theme.C_DIM;
        }

        var mainFont = Graphics.FONT_TINY;
        var detailFont = Graphics.FONT_XTINY;
        var avail = dc.getWidth() - x;
        // The time must always be visible: shrink the font first, then drop the lead.
        if (dc.getTextWidthInPixels(lead + main, mainFont) > avail) {
            mainFont = Graphics.FONT_XTINY;
            if (dc.getTextWidthInPixels(lead + main, mainFont) > avail) {
                lead = "";
            }
        }
        if (dc.getTextWidthInPixels(main, mainFont) > avail && !mainShort.equals("")) {
            main = mainShort;
        }
        if (dc.getTextWidthInPixels(main, mainFont) > avail) {
            main = Graphics.fitTextToArea(main, mainFont, avail, dc.getFontHeight(mainFont), true);
        }
        var mainH = dc.getFontHeight(mainFont);
        var detailH = dc.getFontHeight(detailFont);
        var top = (h - mainH - detailH) / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, top, mainFont, lead, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(mainColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + dc.getTextWidthInPixels(lead, mainFont), top, mainFont, main, Graphics.TEXT_JUSTIFY_LEFT);
        if (dc.getTextWidthInPixels(detail, detailFont) > avail && !detailShort.equals("")) {
            detail = detailShort;
        }
        if (dc.getTextWidthInPixels(detail, detailFont) > avail && !detailTiny.equals("")) {
            detail = detailTiny;
        }
        if (dc.getTextWidthInPixels(detail, detailFont) > avail) {
            detail = Graphics.fitTextToArea(detail, detailFont, avail, detailH, true);
        }
        dc.setColor(detailColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, top + mainH, detailFont, detail, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
