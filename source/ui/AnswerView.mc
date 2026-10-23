import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

// Page 1: the answer. Body Battery ring around the edge, bedtime in the middle.
class AnswerView extends WatchUi.View {

    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        _timer = new Timer.Timer();
        (_timer as Timer.Timer).start(method(:onTick), 60000, true);
    }

    function onHide() as Void {
        if (_timer != null) {
            (_timer as Timer.Timer).stop();
            _timer = null;
        }
    }

    function onTick() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var now = Time.now().value();
        var info = PlanBuilder.build(now);
        var p = info.plan;
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var label = "";
        var big = "";
        var bigFont = Graphics.FONT_MEDIUM;
        var bigColor = Theme.stateColor(p.state);
        var sub = "";
        var subColor = Graphics.COLOR_WHITE;
        var line1 = p.bb == null ? "" : Theme.fmt(Rez.Strings.bbValue, [p.bb]);
        var line2 = "";
        // Shorter alternatives for screens with large fonts.
        var line1Short = "";
        var line2Short = "";

        if (p.state == BedtimeCalc.STATE_PLAN) {
            var bed = p.bedtime as Number;
            label = Theme.str(TimeUtil.czechVe(Theme.hourOf(bed)) ? Rez.Strings.labelSleepAtVe : Rez.Strings.labelSleepAtV);
            big = Theme.hm(bed);
            bigFont = Graphics.FONT_NUMBER_MEDIUM;
            sub = Theme.fmt(Rez.Strings.inDuration, [TimeUtil.formatDuration(bed - now)]);
            line1 = Theme.fmt(Rez.Strings.bbAtBed, [p.bb, p.bbAtBed]);
            line1Short = Theme.fmt(Rez.Strings.bbAtBedShort, [p.bbAtBed]);
            line2 = Theme.fmt(Rez.Strings.targetBy, [info.target, Theme.hm(p.alarm)]);
        } else if (p.state == BedtimeCalc.STATE_NOW) {
            big = Theme.str(Rez.Strings.goToSleepNow);
            sub = Theme.fmt(Rez.Strings.targetBy, [info.target, Theme.hm(p.alarm)]);
        } else if (p.state == BedtimeCalc.STATE_LATE) {
            big = Theme.str(Rez.Strings.sleepNow);
            bigColor = Graphics.COLOR_WHITE;
            sub = Theme.fmt(Rez.Strings.onlyReach, [p.reachable]);
            subColor = Theme.C_RED;
        } else if (p.state == BedtimeCalc.STATE_CHARGED) {
            big = line1;
            line1 = "";
            sub = p.bedtime == null
                ? Theme.str(Rez.Strings.charged)
                : Theme.fmt(Rez.Strings.tonightAround, [Theme.hm(p.bedtime as Number)]);
        } else {
            big = Theme.str(Rez.Strings.AppName);
            sub = Theme.str(Rez.Strings.bbUnavailable);
            subColor = Theme.C_DIM;
        }
        if (info.rateSource == Settings.RATE_LEARNING && p.state != BedtimeCalc.STATE_NO_DATA) {
            line2 = Theme.fmt(Rez.Strings.learning, [info.nights]);
            line2Short = Theme.fmt(Rez.Strings.learningShort, [info.nights]);
        }
        // After waking up: how last night went instead of tonight's plan.
        var morning = MorningData.current(now);
        var ringColor = null;
        if (morning != null) {
            var wakeBB = morning[0] as Number;
            label = Theme.str(Rez.Strings.labelLastNight);
            big = Theme.fmt(Rez.Strings.pctValue, [wakeBB]);
            bigFont = Graphics.FONT_NUMBER_MEDIUM;
            bigColor = MorningData.color(wakeBB, info.target);
            ringColor = bigColor;
            sub = MorningData.lateText(morning[1] as Number);
            subColor = Graphics.COLOR_WHITE;
            line1 = MorningData.streakText(morning[2] as Number, morning[3] as Number);
            line1Short = "";
            line2 = "";
            line2Short = "";
        }
        drawRing(dc, p, ringColor);

        var cx = w / 2;
        var small = Graphics.FONT_XTINY;
        var smallH = dc.getFontHeight(small);
        var subH = dc.getFontHeight(Graphics.FONT_TINY);
        // A text answer ("Go to sleep now") shrinks before it gets truncated.
        if (bigFont == Graphics.FONT_MEDIUM) {
            var fonts = [Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY];
            for (var i = 0; i < fonts.size(); i++) {
                bigFont = fonts[i];
                var fh = dc.getFontHeight(bigFont);
                var top = (h - blockHeight(smallH, fh, subH)) / 2 + smallH;
                if (fit(dc, big, bigFont, top, fh).equals(big)) {
                    break;
                }
            }
        }
        var bigH = dc.getFontHeight(bigFont);
        var y = (h - blockHeight(smallH, bigH, subH)) / 2;
        if (!label.equals("")) {
            var moonR = smallH / 3;
            var lw = dc.getTextWidthInPixels(label, small);
            Theme.drawMoon(dc, cx - lw / 2 - moonR - 4, y + smallH / 2, moonR);
            dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx + moonR, y, small, label, Graphics.TEXT_JUSTIFY_CENTER);
        }
        y += smallH;
        dc.setColor(bigColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, bigFont, fit(dc, big, bigFont, y, bigH), Graphics.TEXT_JUSTIFY_CENTER);
        y += bigH;
        dc.setColor(subColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, Graphics.FONT_TINY, fit(dc, sub, Graphics.FONT_TINY, y, subH), Graphics.TEXT_JUSTIFY_CENTER);
        y += subH + smallH / 3;
        dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, small, fit(dc, pick(dc, line1, line1Short, small, y, smallH), small, y, smallH),
                    Graphics.TEXT_JUSTIFY_CENTER);
        y += smallH;
        dc.drawText(cx, y, small, fit(dc, pick(dc, line2, line2Short, small, y, smallH), small, y, smallH),
                    Graphics.TEXT_JUSTIFY_CENTER);
        drawChevron(dc, cx, (h * 0.90).toNumber());
    }

    // Block of label, big value, sub line and two detail lines, centered vertically.
    private function blockHeight(smallH as Number, bigH as Number, subH as Number) as Number {
        return smallH + bigH + subH + smallH / 3 + 2 * smallH;
    }

    // The full text when it fits the row, otherwise the short variant (if any).
    private function pick(dc as Dc, full as String, short as String, font as Graphics.FontType, y as Number,
                          rowH as Number) as String {
        if (short.equals("") || fit(dc, full, font, y, rowH).equals(full)) {
            return full;
        }
        return short;
    }

    // Truncates text to the width of the round screen at the row's lower edge,
    // inside the ring.
    private function fit(dc as Dc, text as String, font as Graphics.FontType, y as Number,
                         rowH as Number) as String {
        if (text.equals("")) {
            return text;
        }
        var r = dc.getWidth() / 2 - dc.getWidth() / 12;
        var cy = dc.getHeight() / 2;
        var dy = y + rowH - cy;
        if (y < cy) {
            dy = cy - y;
        }
        if (dy >= r) {
            return "";
        }
        var avail = (2 * Math.sqrt(r * r - dy * dy)).toNumber();
        if (dc.getTextWidthInPixels(text, font) <= avail) {
            return text;
        }
        return Graphics.fitTextToArea(text, font, avail, rowH, true);
    }

    // Track + current BB; the darker part is what the evening will still drain.
    // `color` replaces the plan colors (morning summary, no drain part).
    private function drawRing(dc as Dc, p as BedtimePlan, color as Number?) as Void {
        var w = dc.getWidth();
        var pen = w / 25;
        if (pen < 4) {
            pen = 4;
        }
        var r = w / 2 - pen / 2 - 1;
        var cx = w / 2;
        var cy = dc.getHeight() / 2;
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        dc.setPenWidth(pen);
        dc.setColor(Theme.C_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, r);
        if (p.bb != null) {
            var bb = p.bb as Number;
            var atBed = p.bbAtBed == null ? bb : p.bbAtBed as Number;
            if (atBed < 0) {
                atBed = 0;
            }
            if (color != null) {
                drawLevel(dc, cx, cy, r, bb, color);
            } else {
                drawLevel(dc, cx, cy, r, bb, Theme.darkColor(p.state));
                drawLevel(dc, cx, cy, r, atBed, Theme.stateColor(p.state));
            }
        }
        dc.setPenWidth(1);
    }

    // Arc from 12 o'clock clockwise covering `pct` percent of the circle.
    private function drawLevel(dc as Dc, cx as Number, cy as Number, r as Number, pct as Number,
                               color as Number) as Void {
        if (pct <= 0) {
            return;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        if (pct >= 100) {
            dc.drawCircle(cx, cy, r);
            return;
        }
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, 90, 90 - 360 * pct / 100);
    }

    // Small "more below" hint.
    private function drawChevron(dc as Dc, cx as Number, y as Number) as Void {
        var s = dc.getWidth() / 40;
        if (s < 3) {
            s = 3;
        }
        dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(cx - s, y - s / 2, cx, y + s / 2);
        dc.drawLine(cx, y + s / 2, cx + s, y - s / 2);
        dc.setPenWidth(1);
    }
}
