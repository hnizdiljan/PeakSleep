import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.UserProfile;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Time;
import Toybox.Time.Gregorian;

class BedtimeAdvisorView extends WatchUi.View {

    // Labels for UI elements
    private var _wakeUpTimeSetLabel as Text?;
    private var _requiredSleepLabel as Text?;
    private var _idealBedtimeLabel as Text?;
    private var _timeToBedLabel as Text?;
    private var _adviceLabel as Text?;

    // String resources
    private var _fullText as String;
    private var _cannotRechargeText as String;
    private var _tooLateText as String;
    private var _goToSleepInText as String;
    private var _sleepNowText as String; // Or similar for when it's past ideal bedtime but still possible

    function initialize() {
        View.initialize();
        // Load string resources
        _fullText = WatchUi.loadResource(Rez.Strings.valueFull) as String;
        _cannotRechargeText = WatchUi.loadResource(Rez.Strings.valueChargeNotPossible) as String;
        _tooLateText = WatchUi.loadResource(Rez.Strings.bedtimeTooLate) as String; // New string
        _goToSleepInText = WatchUi.loadResource(Rez.Strings.bedtimeGoToSleepIn) as String; // New string
        _sleepNowText = WatchUi.loadResource(Rez.Strings.bedtimeSleepNow) as String; // New string
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.BedtimeAdvisorLayout(dc)); // Will define this layout later

        // Get references to the labels defined in the layout
        _wakeUpTimeSetLabel = findDrawableById("wakeUpTimeSetLabel") as Text?;
        _requiredSleepLabel = findDrawableById("requiredSleepLabel") as Text?;
        _idealBedtimeLabel = findDrawableById("idealBedtimeLabel") as Text?;
        _timeToBedLabel = findDrawableById("timeToBedLabel") as Text?;
        _adviceLabel = findDrawableById("adviceLabel") as Text?;
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        // Potentially start a timer for periodic updates if needed, e.g. for countdown
    }

    // Called when this View is hidden
    function onHide() as Void {
        // Potentially stop the timer
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc); // Call parent onUpdate

        // 1. Get user-defined wake-up time
        var wakeUpHour = Application.Properties.getValue(WAKE_UP_HOUR_KEY);
        var wakeUpMinute = Application.Properties.getValue(WAKE_UP_MINUTE_KEY);

        // Use defaults if not set - these constants were added to PeakSleepApp.mc
        if (wakeUpHour == null) { wakeUpHour = DEFAULT_WAKE_UP_HOUR; }
        if (wakeUpMinute == null) { wakeUpMinute = DEFAULT_WAKE_UP_MINUTE; }

        // Format the wake up time for display
        var wakeUpTimeInfo = new Time.Moment(Time.today().value()).add(new Time.Duration(wakeUpHour * 3600 + wakeUpMinute * 60));
        var wakeUpTimeFormatted = formatMomentToTimeString(wakeUpTimeInfo);


        // --- Reuse logic from PeakSleepView for sleep calculation ---
        // 2. Get Sensor Data (BB)
        var currentBB = getBodyBattery();

        // 3. Get Base Recharge Rate from settings or default
        var baseRechargeRate = getBaseRechargeRate();

        // 4. Calculate Adjusted Recharge Rate (using RHR from PeakSleepView - this might need adjustment if RHR isn't readily available here)
        // For now, let's assume we can get avgHR and restingHR. This might need a shared module or passing data.
        // As a simplification for now, let's use baseRechargeRate directly, or a simplified adjusted rate if HR/RHR is complex to get here.
        // var avgHR = getAverageHeartRate(); // Placeholder - might not be available directly
        // var restingHR = getRestingHeartRate(); // Placeholder
        // var adjustedRechargeRate = calculateAdjustedRechargeRate(baseRechargeRate, avgHR, restingHR);
        var adjustedRechargeRate = baseRechargeRate; // Simplified for now

        // 5. Calculate Needed BB
        var bbNeeded = calculateBbNeeded(currentBB);

        // 6. Calculate Sleep Time
        var sleepTimeHours = calculateSleepTime(bbNeeded, adjustedRechargeRate);
        // --- End of reused logic section ---


        // 7. Calculate Ideal Bedtime
        var idealBedtimeMoment = null as Moment?;
        var timeToBedDuration = null as Duration?;
        var adviceMessage = "";

        if (sleepTimeHours != null && sleepTimeHours > 0) {
            var sleepDurationSeconds = (sleepTimeHours * 3600).toNumber();
            var sleepDuration = new Time.Duration(sleepDurationSeconds);
            
            // Create a Moment for today's wake-up time
            var wakeUpToday = Time.today();
            wakeUpToday = wakeUpToday.add(new Time.Duration(wakeUpHour * Time.Gregorian.SECONDS_PER_HOUR + wakeUpMinute * Time.Gregorian.SECONDS_PER_MINUTE));

            idealBedtimeMoment = wakeUpToday.subtract(sleepDuration);

            // Calculate time remaining to go to bed
            var now = Time.now();
            if (now.lessThan(idealBedtimeMoment)) {
                timeToBedDuration = new Time.Duration(idealBedtimeMoment.value() - now.value());
                adviceMessage = _goToSleepInText;
            } else {
                // It's past the ideal bedtime or very close
                // Check if it's still possible to get full sleep before wakeUpTime
                var potentialWakeUp = now.add(sleepDuration);
                if (potentialWakeUp.lessThan(wakeUpToday) || potentialWakeUp.value() == wakeUpToday.value()) {
                     adviceMessage = _sleepNowText; // Suggest sleeping now
                     // timeToBed will be displayed as 0 or negative, or we can hide it.
                     timeToBedDuration = new Time.Duration(0); // Or handle differently
                } else {
                    adviceMessage = _tooLateText; // Too late for full recharge by alarm
                    idealBedtimeMoment = null; // Can't meet the target
                    timeToBedDuration = null;
                }
            }
        } else if (sleepTimeHours == 0) { // Already full BB
             adviceMessage = _fullText;
        } else { // Cannot recharge
            adviceMessage = _cannotRechargeText;
        }

        // 8. Format and Update UI Labels
        if (_wakeUpTimeSetLabel != null) {
            _wakeUpTimeSetLabel.setText("@ " + wakeUpTimeFormatted);
        }

        if (_requiredSleepLabel != null) {
            if (sleepTimeHours == null) {
                _requiredSleepLabel.setText(_cannotRechargeText);
            } else if (sleepTimeHours <= 0) {
                _requiredSleepLabel.setText(_fullText);
            } else {
                _requiredSleepLabel.setText(formatDurationHoursMinutes(sleepTimeHours));
            }
        }

        if (_idealBedtimeLabel != null) {
            if (idealBedtimeMoment != null) {
                _idealBedtimeLabel.setText("Bed: " + formatMomentToTimeString(idealBedtimeMoment));
            } else {
                 _idealBedtimeLabel.setText("Bed: --:--");
            }
        }
        
        if (_timeToBedLabel != null) {
            if (timeToBedDuration != null && sleepTimeHours != null && sleepTimeHours > 0 && idealBedtimeMoment != null) {
                if (timeToBedDuration.value() > 0) {
                    _timeToBedLabel.setText(formatDurationToHMS(timeToBedDuration));
                } else if (adviceMessage.equals(_sleepNowText)){
                     _timeToBedLabel.setText("Now!");
                } else {
                     _timeToBedLabel.setText(""); // Hide if too late or full
                }
            } else {
                 _timeToBedLabel.setText("");
            }
        }

        if (_adviceLabel != null) {
            _adviceLabel.setText(adviceMessage);
        }
    }

    // Helper to format Time.Moment to HH:MM string
    private function formatMomentToTimeString(moment as Moment) as String {
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        var hours = info.hour.format("%02d");
        var mins = info.min.format("%02d");
        return Lang.format("$1$:$2$", [hours, mins]);
    }

    // Helper to format duration in hours (Float) to Xh Ym string
    private function formatDurationHoursMinutes(totalHours as Float?) as String {
        if (totalHours == null) { return _cannotRechargeText; }
        if (totalHours <= 0) { return _fullText; }

        var hours = totalHours.toNumber();
        var minutes = Math.round((totalHours - hours) * 60).toNumber();

        if (minutes >= 60) { hours += 1; minutes = 0; }
        if (hours == 0 && minutes == 0 && totalHours > 0) { minutes = 1; } // show 1m if very small duration

        return Lang.format("$1$h $2$m", [hours, minutes]);
    }
    
    // Helper to format Time.Duration to H:MM:SS string (or similar)
    private function formatDurationToHMS(duration as Duration) as String {
        var totalSeconds = duration.value();
        if (totalSeconds < 0) { totalSeconds = 0; }

        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        // var seconds = totalSeconds % 60; // Not displaying seconds for brevity

        if (hours > 0) {
            return Lang.format("$1$h $2$m", [hours, minutes.format("%02d")]);
        } else {
            return Lang.format("$1$m", [minutes]);
        }
    }

    // --- Functions potentially reused/adapted from PeakSleepView ---
    // These will need to be implemented or PeakSleepView's functions made accessible (e.g. via a common module or inheritance)
    // For now, I'll add stubs or simplified versions.

    private function getBodyBattery() as Number? {
        if (Toybox.SensorHistory has :getBodyBatteryHistory) {
            var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period=>1, :order=>SensorHistory.ORDER_NEWEST_FIRST});
            if (bbIterator != null) {
                var sample = bbIterator.next();
                if (sample != null && sample.data != null) {
                    return sample.data as Number;
                }
            }
        }
        return null;
    }

    private function getBaseRechargeRate() as Float {
        var rate = Application.Properties.getValue(BASE_RECHARGE_RATE_KEY);
        if (rate instanceof Number) { return rate.toFloat(); }
        if (rate instanceof Float) { return rate; }
        return DEFAULT_RECHARGE_RATE;
    }

    private function calculateBbNeeded(currentBB as Number?) as Number {
        if (currentBB == null) { return 100; }
        if (currentBB >= 100) { return 0; }
        return 100 - currentBB;
    }

    private function calculateSleepTime(bbNeeded as Number, rechargeRate as Float) as Float? {
        if (rechargeRate <= 0) { return null; }
        if (bbNeeded <= 0) { return 0.0f; }
        return bbNeeded / rechargeRate;
    }

    // NOTE: calculateAdjustedRechargeRate and getting HR/RHR would be more complex
    // and might be best handled by refactoring PeakSleepView if this app grows,
    // or by simplifying the logic here if precise HR-based adjustment isn't critical for this specific view.
    // For now, adjustedRechargeRate is just using baseRechargeRate in onUpdate.
} 