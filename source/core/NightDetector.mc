import Toybox.Lang;

// One detected night of sleep.
class Night {
    public var onsetT as Number;
    public var onsetBB as Number;
    public var wakeT as Number;
    public var wakeBB as Number;
    // Evening drain before onset (BB per hour), null when unknown.
    public var drain as Float?;

    function initialize(onsetT as Number, onsetBB as Number, wakeT as Number, wakeBB as Number,
                        drain as Float?) {
        self.onsetT = onsetT;
        self.onsetBB = onsetBB;
        self.wakeT = wakeT;
        self.wakeBB = wakeBB;
        self.drain = drain;
    }

    // Recharge rate in BB per hour.
    function rate() as Float {
        var hours = (wakeT - onsetT) / 3600.0;
        return hours > 0 ? (wakeBB - onsetBB) / hours : 0.0;
    }

    function toArray() as Array {
        return [onsetT, onsetBB, wakeT, wakeBB, drain];
    }

    static function fromArray(a as Array) as Night {
        return new Night(a[0] as Number, a[1] as Number, a[2] as Number, a[3] as Number, a[4] as Float?);
    }
}

module NightDetector {

    const MIN_SLEEP = 10800;
    const MIN_RATE = 2.0;
    const MAX_RATE = 30.0;
    const DRAIN_LOOKBACK = 10800;
    const MIN_DRAIN_SPAN = 3600;
    const MAX_DRAIN = 15.0;

    // Finds the night inside [ws, we] as the largest Body Battery rise
    // (lowest sample before highest sample). Returns null without a rise.
    function detect(buf as Array<Number>, ws as Number, we as Number) as Night? {
        var minIdx = -1;
        var bestFrom = -1;
        var bestTo = -1;
        var bestRise = 0;
        for (var i = 0; i + 1 < buf.size(); i += 2) {
            var t = buf[i];
            if (t < ws || t > we) {
                continue;
            }
            if (minIdx < 0 || buf[i + 1] < buf[minIdx + 1]) {
                minIdx = i;
            }
            var rise = buf[i + 1] - buf[minIdx + 1];
            if (rise > bestRise) {
                bestRise = rise;
                bestFrom = minIdx;
                bestTo = i;
            }
        }
        if (bestFrom < 0) {
            return null;
        }
        // Once the battery is full the rest of the night adds nothing.
        for (var j = bestFrom; j < bestTo; j += 2) {
            if (buf[j + 1] >= 100) {
                bestTo = j;
                break;
            }
        }
        var onsetT = buf[bestFrom];
        return new Night(onsetT, buf[bestFrom + 1], buf[bestTo], buf[bestTo + 1],
                         eveningDrain(buf, onsetT, buf[bestFrom + 1]));
    }

    // Drain rate over the hours before onset, from the earliest sample in the lookback.
    function eveningDrain(buf as Array<Number>, onsetT as Number, onsetBB as Number) as Float? {
        for (var i = 0; i + 1 < buf.size(); i += 2) {
            var t = buf[i];
            if (t >= onsetT - DRAIN_LOOKBACK && t < onsetT) {
                if (onsetT - t < MIN_DRAIN_SPAN) {
                    return null;
                }
                var d = (buf[i + 1] - onsetBB) / ((onsetT - t) / 3600.0);
                if (d < 0) {
                    d = 0.0;
                }
                return d > MAX_DRAIN ? MAX_DRAIN : d;
            }
        }
        return null;
    }

    function isValid(n as Night) as Boolean {
        if (n.wakeT - n.onsetT < MIN_SLEEP) {
            return false;
        }
        var r = n.rate();
        return r >= MIN_RATE && r <= MAX_RATE;
    }

    function median(vals as Array<Float>) as Float? {
        var n = vals.size();
        if (n == 0) {
            return null;
        }
        var s = vals.slice(0, null) as Array<Float>;
        // insertion sort: at most 7 values
        for (var i = 1; i < n; i++) {
            var v = s[i];
            var j = i - 1;
            while (j >= 0 && s[j] > v) {
                s[j + 1] = s[j];
                j--;
            }
            s[j + 1] = v;
        }
        if (n % 2 == 1) {
            return s[n / 2];
        }
        return (s[n / 2 - 1] + s[n / 2]) / 2.0;
    }
}
