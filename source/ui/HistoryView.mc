import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Page 3: recharge rate of the last learned nights.
class HistoryView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var font = Graphics.FONT_XTINY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, (h * 0.14).toNumber(), font, Theme.str(Rez.Strings.historyTitle),
                    Graphics.TEXT_JUSTIFY_CENTER);

        var nights = Learning.nights();
        if (nights.size() == 0) {
            var text = Graphics.fitTextToArea(Theme.str(Rez.Strings.historyEmpty), font,
                                              (w * 0.7).toNumber(), (h * 0.4).toNumber(), true);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var target = Settings.target();
        var rates = [] as Array<Float>;
        var maxRate = 10.0;
        var sleepSum = 0;
        for (var i = 0; i < nights.size(); i++) {
            var r = nights[i].rate();
            rates.add(r);
            if (r > maxRate) {
                maxRate = r;
            }
            sleepSum += nights[i].wakeT - nights[i].onsetT;
        }

        // Up to 7 bars, newest on the right; green = target reached that night.
        var areaW = (w * 0.6).toNumber();
        var slot = areaW / LearningMath.MAX_NIGHTS;
        var barW = (slot * 0.7).toNumber();
        var baseY = (h * 0.62).toNumber();
        var maxH = (h * 0.32).toNumber();
        var x0 = (w - slot * nights.size()) / 2;
        for (var i = 0; i < nights.size(); i++) {
            var bh = (maxH * rates[i] / maxRate).toNumber();
            if (bh < 2) {
                bh = 2;
            }
            dc.setColor(nights[i].wakeBB >= target ? Theme.C_GREEN : Theme.C_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x0 + i * slot + (slot - barW) / 2, baseY - bh, barW, bh);
        }
        dc.setColor(Theme.C_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x0, baseY + 1, x0 + slot * nights.size(), baseY + 1);

        var avgRate = NightDetector.median(rates) as Float;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, baseY + dc.getFontHeight(font) / 2, font,
                    Theme.fmt(Rez.Strings.historyAvg, [avgRate.format("%.1f"),
                              TimeUtil.formatDuration(sleepSum / nights.size())]),
                    Graphics.TEXT_JUSTIFY_CENTER);
    }
}
