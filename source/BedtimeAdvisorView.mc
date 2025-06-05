import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.UserProfile;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Time;
import Toybox.Time.Gregorian;

// SleepLogic module is expected to be in the same source directory
// Constants like WAKE_UP_HOUR_KEY, DEFAULT_WAKE_UP_HOUR are expected from PeakSleepApp.mc

class BedtimeAdvisorView extends WatchUi.View {

    // Labels for UI elements
    private var _wakeUpTimeSetLabel as Text?;
    private var _requiredSleepLabel as Text?;
    private var _idealBedtimeLabel as Text?;
    private var _promptMessageLabel as Text?;
    private var _mainAdviceValueLabelTime as Text?;
    private var _mainAdviceValueLabelTooLate as Text?;

    // String resources
    private var _fullText as String;
    private var _cannotRechargeText as String;
    private var _goToSleepInText as String;
    private var _sleepNowText as String;

    function initialize() {
        View.initialize();
        _fullText = WatchUi.loadResource(Rez.Strings.valueFull) as String;
        _cannotRechargeText = WatchUi.loadResource(Rez.Strings.valueChargeNotPossible) as String;
        _goToSleepInText = WatchUi.loadResource(Rez.Strings.bedtimeGoToSleepIn) as String;
        _sleepNowText = WatchUi.loadResource(Rez.Strings.bedtimeSleepNow) as String;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.BedtimeAdvisorLayout(dc));
        _wakeUpTimeSetLabel = findDrawableById("wakeUpTimeSetLabel") as Text?;
        _requiredSleepLabel = findDrawableById("requiredSleepLabel") as Text?;
        _idealBedtimeLabel = findDrawableById("idealBedtimeLabel") as Text?;
        _promptMessageLabel = findDrawableById("promptMessageLabel") as Text?;
        _mainAdviceValueLabelTime = findDrawableById("mainAdviceValueLabelTime") as Text?;
        _mainAdviceValueLabelTooLate = findDrawableById("mainAdviceValueLabelTooLate") as Text?;
    }

    function onShow() as Void {
        // Sensor enabling is now handled by SleepLogic.getAverageHeartRate if needed
    }

    function onHide() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var wakeUpHour = Application.Properties.getValue(WAKE_UP_HOUR_KEY) as Number?;
        var wakeUpMinute = Application.Properties.getValue(WAKE_UP_MINUTE_KEY) as Number?;

        if (wakeUpHour == null) { wakeUpHour = DEFAULT_WAKE_UP_HOUR; }
        if (wakeUpMinute == null) { wakeUpMinute = DEFAULT_WAKE_UP_MINUTE; }

        var wakeUpTimeInfo = new Time.Moment(Time.today().value()).add(new Time.Duration(wakeUpHour * 3600 + wakeUpMinute * 60));
        var wakeUpTimeFormatted = formatMomentToTimeString(wakeUpTimeInfo);

        var currentBB = SleepLogic.getBodyBattery();
        var avgHR = SleepLogic.getAverageHeartRate(); // Get real avgHR
        var restingHR = SleepLogic.getRestingHeartRate(); // Get real rHR
        var baseRechargeRate = SleepLogic.getBaseRechargeRate();
        // Calculate adjusted rate using full logic from SleepLogic
        var adjustedRechargeRate = SleepLogic.calculateAdjustedRechargeRate(baseRechargeRate, avgHR, restingHR);
        var bbNeeded = SleepLogic.calculateBbNeeded(currentBB);
        var sleepTimeHours = SleepLogic.calculateSleepTime(bbNeeded, adjustedRechargeRate);

        var idealBedtimeMoment = null as Moment?;
        var promptMsg = "";

        var now = Time.now();

        if (sleepTimeHours != null && sleepTimeHours > 0) {
            var sleepDurationSeconds = (sleepTimeHours * 3600).toNumber();
            var sleepDuration = new Time.Duration(sleepDurationSeconds);
            
            var wakeUpToday = Time.today();
            wakeUpToday = wakeUpToday.add(new Time.Duration(wakeUpHour * Time.Gregorian.SECONDS_PER_HOUR + wakeUpMinute * Time.Gregorian.SECONDS_PER_MINUTE));
            if (now.value() >= wakeUpToday.value()) {
                // Pokud už je po budíku, posuň na další den
                wakeUpToday = wakeUpToday.add(new Time.Duration(24 * 3600));
            }

            idealBedtimeMoment = wakeUpToday.subtract(sleepDuration);

            if (now.lessThan(idealBedtimeMoment)) {
                promptMsg = _goToSleepInText;
            } else {
                var potentialWakeUp = now.add(sleepDuration);
                if (potentialWakeUp.lessThan(wakeUpToday) || potentialWakeUp.value() == wakeUpToday.value()) {
                     promptMsg = "";
                } else {
                    promptMsg = "";
                    idealBedtimeMoment = null;
                }
            }
        } else if (sleepTimeHours != null && sleepTimeHours == 0) {
             promptMsg = "";
        } else { 
            promptMsg = "";
        }

        if (_wakeUpTimeSetLabel != null) {
            _wakeUpTimeSetLabel.setText("Alarm: " + wakeUpTimeFormatted);
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
                _idealBedtimeLabel.setText("To Bed: " + formatMomentToTimeString(idealBedtimeMoment));
            } else {
                 _idealBedtimeLabel.setText("To Bed: --:--");
            }
        }
        if (_promptMessageLabel != null) {
            _promptMessageLabel.setText(promptMsg);
        }

        // --- Nastavení hlavního sdělení (čas, Sleep now, Too late) ---
        if (_mainAdviceValueLabelTime != null) {
            _mainAdviceValueLabelTime.setText("");
        }
        if (_mainAdviceValueLabelTooLate != null) {
            _mainAdviceValueLabelTooLate.setText("");
        }
        if (sleepTimeHours != null && sleepTimeHours > 0 && idealBedtimeMoment != null) {
            if (now.lessThan(idealBedtimeMoment)) {
                // Zobraz čas, za jak dlouho jít spát
                var timeToBedDurationValue = new Time.Duration(idealBedtimeMoment.value() - now.value());
                _mainAdviceValueLabelTime.setText(formatDurationToHMS(timeToBedDurationValue));
                _mainAdviceValueLabelTime.setFont(Graphics.FONT_TINY);
            } else {
                // Zobraz "Sleep now"
                _mainAdviceValueLabelTime.setText(_sleepNowText);
                _mainAdviceValueLabelTime.setFont(Graphics.FONT_TINY);
            }
        } else if (sleepTimeHours != null && sleepTimeHours > 0 && idealBedtimeMoment == null) {
            // Zobraz "Too late for full recharge!"
            _mainAdviceValueLabelTooLate.setText("Too late\nfor full recharge!");
            _mainAdviceValueLabelTooLate.setFont(Graphics.FONT_TINY);
        }
    }

    // Helper to format Time.Moment to HH:MM string (UI specific)
    private function formatMomentToTimeString(moment as Moment) as String {
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        return Lang.format("$1$:$2$", [info.hour.format("%02d"), info.min.format("%02d")]);
    }

    // Helper to format duration in hours (Float) to Xh Ym string (UI specific)
    private function formatDurationHoursMinutes(totalHours as Float?) as String {
        if (totalHours == null) { return _cannotRechargeText; }
        if (totalHours <= 0) { return _fullText; }
        var hours = totalHours.toNumber();
        var minutes = Math.round((totalHours - hours) * 60).toNumber();
        if (minutes >= 60) { hours += 1; minutes = 0; }
        if (hours == 0 && minutes == 0 && totalHours > 0) { minutes = 1; }
        return Lang.format("$1$h $2$m", [hours, minutes.format("%02d")]);
    }
    
    // Helper to format Time.Duration to H:MM:SS string (UI specific)
    private function formatDurationToHMS(duration as Duration) as String {
        var totalSeconds = duration.value();
        if (totalSeconds < 0) { totalSeconds = 0; }
        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        if (hours > 0) {
            return Lang.format("$1$h $2$m", [hours, minutes.format("%02d")]);
        } else {
            return Lang.format("$1$m", [minutes]);
        }
    }

    // Removed getBodyBattery, getBaseRechargeRate, calculateBbNeeded, calculateSleepTime
    // as they are now in SleepLogic module.
} 