import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Picks one number: up/down (or swipes) change it, select confirms, back cancels.
class StepperView extends WatchUi.View {

    public var value as Number;
    private var _title as String;
    private var _format as String;

    function initialize(title as String, value as Number, format as String) {
        View.initialize();
        _title = title;
        self.value = value;
        _format = format;
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Theme.C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, (h * 0.18).toNumber(), Graphics.FONT_XTINY, _title, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Theme.C_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h / 2, Graphics.FONT_NUMBER_MEDIUM, value.format(_format),
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // up / down hints
        var s = w / 30 + 3;
        var top = (h * 0.30).toNumber();
        var bottom = (h * 0.70).toNumber();
        dc.fillPolygon([[w / 2 - s, top + s], [w / 2 + s, top + s], [w / 2, top]]);
        dc.fillPolygon([[w / 2 - s, bottom - s], [w / 2 + s, bottom - s], [w / 2, bottom]]);
    }
}

class StepperDelegate extends WatchUi.BehaviorDelegate {

    private var _view as StepperView;
    private var _min as Number;
    private var _max as Number;
    private var _step as Number;
    private var _onDone as Method(value as Number) as Void;

    function initialize(view as StepperView, min as Number, max as Number, step as Number,
                        onDone as Method(value as Number) as Void) {
        BehaviorDelegate.initialize();
        _view = view;
        _min = min;
        _max = max;
        _step = step;
        _onDone = onDone;
    }

    // Up button / swipe down: increase.
    function onPreviousPage() as Boolean {
        change(_step);
        return true;
    }

    // Down button / swipe up: decrease.
    function onNextPage() as Boolean {
        change(-_step);
        return true;
    }

    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        _onDone.invoke(_view.value);
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    // Wraps around at the ends so long ranges stay quick to reach.
    private function change(delta as Number) as Void {
        var v = _view.value + delta;
        if (v > _max) {
            v = _min;
        } else if (v < _min) {
            v = _max;
        }
        _view.value = v;
        WatchUi.requestUpdate();
    }
}

function pushStepper(title as ResourceId, value as Number, min as Number, max as Number, step as Number,
                     format as String, onDone as Method(value as Number) as Void) as Void {
    var view = new StepperView(Theme.str(title), value, format);
    WatchUi.pushView(view, new StepperDelegate(view, min, max, step, onDone), WatchUi.SLIDE_LEFT);
}
