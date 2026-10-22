import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

// Runs every 30 minutes in the background and stores one Body Battery sample.
(:background)
class SampleService extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        try {
            var buf = Application.Storage.getValue(SampleStore.KEY) as Array<Number>?;
            Application.Storage.setValue(SampleStore.KEY, SampleBuffer.append(buf, Time.now().value(),
                BodyBatteryReader.read(), SampleBuffer.MAX_PAIRS, SampleBuffer.MIN_GAP));
        } catch (e) {
            // Storage unavailable: skip this sample.
        }
        Background.exit(null);
    }
}

(:background)
module SampleStore {
    const KEY = "samples";
}
