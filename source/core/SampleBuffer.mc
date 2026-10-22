import Toybox.Lang;

// Flat ring buffer of Body Battery samples: [t0, bb0, t1, bb1, ...], oldest first.
(:background)
module SampleBuffer {

    // 48 h of 30-minute samples.
    const MAX_PAIRS = 96;
    // A new sample this close to the last one replaces it.
    const MIN_GAP = 600;

    function append(buf as Array<Number>?, t as Number, bb as Number?, maxPairs as Number,
                    minGap as Number) as Array<Number> {
        var out = (buf == null ? [] : buf) as Array<Number>;
        if (bb == null) {
            return out;
        }
        var n = out.size();
        if (n >= 2 && t - out[n - 2] < minGap) {
            out[n - 2] = t;
            out[n - 1] = bb;
            return out;
        }
        out.add(t);
        out.add(bb);
        var extra = out.size() - maxPairs * 2;
        if (extra > 0) {
            out = out.slice(extra, null);
        }
        return out;
    }
}
