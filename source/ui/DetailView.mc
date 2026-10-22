import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

// Page 2: why this bedtime — inputs of the calculation.
class DetailView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var info = PlanBuilder.build(Time.now().value());
        var p = info.plan;
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var font = Graphics.FONT_XTINY;
        var fh = dc.getFontHeight(font);
        var title = p.bedtime == null
            ? Theme.str(Rez.Strings.AppName)
            : Theme.fmt(Rez.Strings.whyTitle, [Theme.hm(p.bedtime as Number)]);
        dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, (h * 0.14).toNumber(), font, title, Graphics.TEXT_JUSTIFY_CENTER);

        var left = (w * 0.16).toNumber();
        var right = w - left;
        var y = (h * 0.25).toNumber();
        var step = (fh * 1.25).toNumber();

        var bbVal = p.bb == null ? "--" : Theme.fmt(Rez.Strings.pctValue, [p.bb]);
        row(dc, left, right, y, Rez.Strings.rowBbNow, bbVal, Theme.stateColor(p.state));
        y += step;

        var drainRate = info.drain.format("%.1f") + "/h";
        if (p.bb != null && p.bbAtBed != null && p.state == BedtimeCalc.STATE_PLAN) {
            row(dc, left, right, y, Rez.Strings.rowDrain,
                "-" + ((p.bb as Number) - (p.bbAtBed as Number)).format("%d"), Graphics.COLOR_WHITE);
            y += fh;
            dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
            dc.drawText(right, y, font, drainRate, Graphics.TEXT_JUSTIFY_RIGHT);
        } else {
            row(dc, left, right, y, Rez.Strings.rowDrain, drainRate, Graphics.COLOR_WHITE);
        }
        y += step;

        row(dc, left, right, y, Rez.Strings.rowRate, info.rate.format("%.1f") + "/h", Theme.C_GREEN);
        y += fh;
        dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(right, y, font, sourceText(info), Graphics.TEXT_JUSTIFY_RIGHT);
        y += step;

        row(dc, left, right, y, Rez.Strings.rowTarget,
            Theme.fmt(Rez.Strings.targetBy, [info.target, Theme.hm(p.alarm)]), Graphics.COLOR_WHITE);
    }

    private function row(dc as Dc, left as Number, right as Number, y as Number, label as ResourceId,
                         value as String, color as Number) as Void {
        var font = Graphics.FONT_XTINY;
        dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left, y, font, Theme.str(label), Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(right, y, font, value, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function sourceText(info as PlanInfo) as String {
        if (info.rateSource == Settings.RATE_AUTO) {
            var words = [Rez.Strings.nightOne, Rez.Strings.nightFew, Rez.Strings.nightMany];
            return Theme.fmt(Rez.Strings.srcAuto, [info.nights, Theme.str(words[TimeUtil.pluralIndex(info.nights)])]);
        }
        if (info.rateSource == Settings.RATE_LEARNING) {
            return Theme.fmt(Rez.Strings.learning, [info.nights]);
        }
        return Theme.str(Rez.Strings.srcManual);
    }
}
