import Toybox.Lang;
import Toybox.SensorHistory;

// Reads the latest Body Battery value. Only ever asks for a single sample:
// longer history reads run out of memory on some devices.
(:background, :glance)
module BodyBatteryReader {

    function read() as Number? {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getBodyBatteryHistory)) {
            return null;
        }
        try {
            var iter = SensorHistory.getBodyBatteryHistory({ :period => 1 });
            var sample = iter.next();
            if (sample == null || sample.data == null) {
                return null;
            }
            var bb = (sample.data as Numeric).toNumber();
            if (bb < 0 || bb > 100) {
                return null;
            }
            return bb;
        } catch (e) {
            return null;
        }
    }
}
