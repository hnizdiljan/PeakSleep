import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const PAGE_ANSWER = 0;
const PAGE_DETAIL = 1;
const PAGE_HISTORY = 2;

function makePage(index as Number) as WatchUi.View {
    if (index == PAGE_DETAIL) {
        return new DetailView();
    }
    if (index == PAGE_HISTORY) {
        return new HistoryView();
    }
    return new AnswerView();
}

// True when the app is opened from a glance (most devices). Otherwise page 1
// lives in the widget carousel, where up/down belong to the system.
function opensFromGlance() as Boolean {
    var ds = System.getDeviceSettings();
    return (ds has :isGlanceModeEnabled) && ds.isGlanceModeEnabled;
}

// Paging: down/swipe up = next page, up/swipe down = previous, back = leave.
class PageDelegate extends WatchUi.BehaviorDelegate {

    private var _index as Number;
    private var _inCarousel as Boolean;

    function initialize(index as Number, inCarousel as Boolean) {
        BehaviorDelegate.initialize();
        _index = index;
        _inCarousel = inCarousel;
    }

    function onNextPage() as Boolean {
        if (_inCarousel && _index == PAGE_ANSWER) {
            return false;
        }
        go(_index + 1, WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as Boolean {
        if (_inCarousel && _index == PAGE_ANSWER) {
            return false;
        }
        var first = _inCarousel ? PAGE_DETAIL : PAGE_ANSWER;
        if (_index - 1 >= first) {
            go(_index - 1, WatchUi.SLIDE_DOWN);
        }
        return true;
    }

    function onSelect() as Boolean {
        if (_index != PAGE_ANSWER) {
            return true;
        }
        if (_inCarousel) {
            WatchUi.pushView(makePage(PAGE_DETAIL), new PageDelegate(PAGE_DETAIL, true), WatchUi.SLIDE_UP);
        } else {
            go(PAGE_DETAIL, WatchUi.SLIDE_UP);
        }
        return true;
    }

    function onBack() as Boolean {
        if (_inCarousel && _index != PAGE_ANSWER) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        return false;
    }

    function onMenu() as Boolean {
        return false;
    }

    private function go(index as Number, transition as WatchUi.SlideType) as Void {
        if (index > PAGE_HISTORY) {
            return;
        }
        WatchUi.switchToView(makePage(index), new PageDelegate(index, _inCarousel), transition);
    }
}
