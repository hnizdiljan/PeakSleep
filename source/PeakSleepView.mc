import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.UserProfile;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application.Storage;
import Toybox.Activity;
import Toybox.SensorHistory;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Application;

class PeakSleepView extends WatchUi.View {

    // References to UI labels (will be initialized in onLayout)
    private var _bodyBatteryValueLabel as Text?;
    private var _heartRateValueLabel as Text?;
    private var _estSleepValueLabel as Text?;
    private var _rhrValueLabel as Text?;
    private var _rechargeRateValueLabel as Text?;
    private var _wakeUpTimeLabel as Text?;

    private var _lastSleepValue as Float?;
    private var _updateTimer as Timer.Timer?;

    private var _naText as String;
    private var _fullText as String;
    private var _cannotRechargeText as String;


    function initialize() {
        View.initialize();
        _naText = WatchUi.loadResource(Rez.Strings.valueNotAvailable) as String;
        _fullText = WatchUi.loadResource(Rez.Strings.valueFull) as String;
        _cannotRechargeText = WatchUi.loadResource(Rez.Strings.valueChargeNotPossible) as String;
        _lastSleepValue = null;
        _updateTimer = null;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        // Get references to the labels defined in the layout
        _bodyBatteryValueLabel = findDrawableById("bodyBatteryValue") as Text;
        _heartRateValueLabel = findDrawableById("heartRateValue") as Text;
        _estSleepValueLabel = findDrawableById("estSleepValue") as Text;
        _rhrValueLabel = findDrawableById("rhrValue") as Text;
        _rechargeRateValueLabel = findDrawableById("rechargeRateValue") as Text;
        _wakeUpTimeLabel = findDrawableById("wakeUpTime") as Text;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        // Enable heart rate sensor to make sure we can get current values
        if (Sensor has :setEnabledSensors) {
            System.println("PeakSleepView: Enabling heart rate sensor");
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        } else {
            System.println("PeakSleepView: Cannot enable sensors, method not available");
        }
        
        // Set up timer for periodic updates
        if (_updateTimer == null) {
            _updateTimer = new Timer.Timer();
            _updateTimer.start(method(:onTimerTick), 5000, true);
        }
    }
    
    // Timer callback for periodic updates
    function onTimerTick() as Void {
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // 1. Get Sensor Data (BB, HR, RHR)
        var currentBB = getBodyBattery();
        var avgHR = getAverageHeartRate();
        var restingHR = getRestingHeartRate();

        // 2. Get Base Recharge Rate from settings or default
        var baseRechargeRate = getBaseRechargeRate(); 

        // 3. Calculate Adjusted Recharge Rate (Optional stress factor)
        var adjustedRechargeRate = calculateAdjustedRechargeRate(baseRechargeRate, avgHR, restingHR);

        // 4. Calculate Needed BB
        var bbNeeded = calculateBbNeeded(currentBB);

        // 5. Calculate Sleep Time
        var sleepTimeHours = calculateSleepTime(bbNeeded, adjustedRechargeRate);
        
        // 6. Calculate Wake-up Time
        var wakeUpTime = calculateWakeUpTime(sleepTimeHours);

        // 7. Format and Update UI Labels
        updateUiLabels(dc, currentBB, avgHR, restingHR, adjustedRechargeRate, sleepTimeHours, bbNeeded, wakeUpTime);

        // Call the parent onUpdate function to draw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        // Stop update timer when view is hidden
        if (_updateTimer != null) {
            _updateTimer.stop();
            _updateTimer = null;
        }
    }

    // --- Helper Functions --- 

    private function getBodyBattery() as Number? {
        System.println("PeakSleepView: getBodyBattery() called");
        
        // Try SensorHistory method first - this is the current API for most devices
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            System.println("PeakSleepView: Using SensorHistory.getBodyBatteryHistory");
            var bbIter = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            if (bbIter != null) {
                var sample = bbIter.next();
                if (sample != null && sample.data != null) {
                    System.println("PeakSleepView: Returning BB from SensorHistory: " + sample.data);
                    return sample.data;
                } else {
                    System.println("PeakSleepView: Sample or sample.data is null from SensorHistory");
                }
            } else {
                System.println("PeakSleepView: bbIter is null from SensorHistory");
            }
        } else {
            System.println("PeakSleepView: SensorHistory method not available");
        }
        
        // Try UserProfile methods as fallback for older firmware versions
        if ((UserProfile has :getBodyBatteryHistory)) {
            System.println("PeakSleepView: Using UserProfile.getBodyBatteryHistory");
            var bbIterator = UserProfile.getBodyBatteryHistory({:period=>1}); // Get latest value
            System.println("PeakSleepView: bbIterator from getBodyBatteryHistory(): " + bbIterator);
            if (bbIterator != null) {
                 var sample = bbIterator.next();
                 System.println("PeakSleepView: sample from bbIterator: " + sample);
                 if (sample != null && sample.data != null) {
                     System.println("PeakSleepView: Returning BB from history: " + sample.data);
                     return sample.data;
                 } else {
                     System.println("PeakSleepView: Sample or sample.data is null from history");
                 }
            } else {
                System.println("PeakSleepView: bbIterator is null");
            }
        } else {
            System.println("PeakSleepView: UserProfile has no :getBodyBatteryHistory");
        }
        
        // Last resort for older devices/API levels
        if ((UserProfile has :getBodyBattery)) {
             System.println("PeakSleepView: Using UserProfile.getBodyBattery");
             var bbDirect = UserProfile.getBodyBattery();
             System.println("PeakSleepView: bbDirect from getBodyBattery(): " + bbDirect);
             if (bbDirect != null) {
                 System.println("PeakSleepView: Returning BB direct: " + bbDirect);
                 return bbDirect;
             } else {
                System.println("PeakSleepView: bbDirect is null");
             }
        } else {
            System.println("PeakSleepView: UserProfile has no :getBodyBattery");
        }
        
        System.println("PeakSleepView: getBodyBattery() returning null");
        return null;
    }

    // New method to get average heart rate over the last 2 hours
    private function getAverageHeartRate() as Number? {
        System.println("PeakSleepView: getAverageHeartRate() called");
        
        // Enable HR sensor
        if (Sensor has :setEnabledSensors) {
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        }
        
        // Get average heart rate over last 2 hours
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
            var twoHoursInSeconds = 2 * 60 * 60; // 2 hours in seconds
            var hrIter = Toybox.SensorHistory.getHeartRateHistory({:period => twoHoursInSeconds});
            
            if (hrIter != null) {
                var sum = 0;
                var count = 0;
                var sample;
                
                // Calculate average from samples
                sample = hrIter.next();
                while (sample != null) {
                    if (sample.data != null && sample.data > 0) {
                        sum += sample.data;
                        count++;
                    }
                    sample = hrIter.next();
                }
                
                // Return average if we have samples
                if (count > 0) {
                    System.println("PeakSleepView: Returning average HR from " + count + " samples: " + (sum / count));
                    return (sum / count).toNumber();
                }
            }
        }
        
        // Fallback to current HR if averaging fails
        System.println("PeakSleepView: Falling back to current HR");
        var sensorInfo = Sensor.getInfo();
        if (sensorInfo != null && (sensorInfo has :currentHeartRate) && sensorInfo.currentHeartRate != null) {
            return sensorInfo.currentHeartRate;
        }
        
        return null;
    }

    // Updated to estimate RHR from heart rate history or use UserProfile
    private function getRestingHeartRate() as Number? {
        System.println("PeakSleepView: getRestingHeartRate() called");
        
        // Try to estimate RHR by finding minimum HR over past 24 hours
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
            System.println("PeakSleepView: Trying to estimate RHR from heart rate history");
            
            // Set longer period for more accurate RHR assessment (24 hours)
            var oneDayInSeconds = 24 * 60 * 60;
            var hrIter = Toybox.SensorHistory.getHeartRateHistory({:period => oneDayInSeconds});
            
            if (hrIter != null) {
                var minHR = null;
                var sample;
                
                // Find minimum heart rate value
                sample = hrIter.next();
                while (sample != null) {
                    if (sample.data != null && sample.data > 30) { // Filter out likely erroneous values below 30
                        if (minHR == null || sample.data < minHR) {
                            minHR = sample.data;
                        }
                    }
                    sample = hrIter.next();
                }
                
                if (minHR != null) {
                    System.println("PeakSleepView: Estimated RHR from history minimum: " + minHR);
                    return minHR;
                }
            }
        }
        
        // Fallback to profile value
        var profile = UserProfile.getProfile();
        if (profile != null && profile.restingHeartRate != null) {
            System.println("PeakSleepView: Returning RHR from profile: " + profile.restingHeartRate);
            return profile.restingHeartRate;
        }
        
        return null;
    }

    private function getBaseRechargeRate() as Float {
        var rate = Toybox.Application.Properties.getValue("baseRechargeRate"); 
        if (rate instanceof Number) { // Check if it's a number (could be Float or Number)
            return rate.toFloat();
        }
         if (rate instanceof Float) {
            return rate;
        }
        // Return default if not set or invalid type
        return DEFAULT_RECHARGE_RATE;
    }

    private function calculateAdjustedRechargeRate(baseRate as Float, hr as Number?, rhr as Number?) as Float {
        // Basic implementation without stress factor for now
        // TODO: Implement optional stress adjustment later if desired
         if (hr != null && rhr != null && hr > rhr + 5) { 
            var stressFactor = hr - rhr - 5;
            // Simple linear reduction: reduce rate by 1% per BPM over RHR+5 
            // Ensure rate doesn't go below 50% of base 
            var adjusted = baseRate * (1.0 - (stressFactor * 0.01));
            var minRate = baseRate * 0.5;
             return adjusted > minRate ? adjusted : minRate;
        } 
        return baseRate;
    }

    private function calculateBbNeeded(currentBB as Number?) as Number {
        if (currentBB == null) {
            return 100; // Assume worst case if data unavailable
        }
        if (currentBB >= 100) {
            return 0;
        }
        return 100 - currentBB;
    }

    private function calculateSleepTime(bbNeeded as Number, rechargeRate as Float) as Float? {
         if (rechargeRate <= 0) {
             return null; // Cannot recharge
         }
         if (bbNeeded <= 0) {
             return 0.0f;
         }
         return bbNeeded / rechargeRate;
    }
    
    // New function to calculate wake-up time
    private function calculateWakeUpTime(sleepTimeHours as Float?) as String {
        if (sleepTimeHours == null || sleepTimeHours <= 0) {
            return "";
        }
        
        // Get current time
        var now = Time.now();
        
        // Convert sleep hours to seconds
        var sleepSeconds = (sleepTimeHours * 3600).toNumber();
        
        // Add sleep duration to current time
        var wakeUpMoment = new Time.Moment(now.value() + sleepSeconds);
        
        // Format wake-up time
        var timeFormat = "$1$:$2$";
        var info = Gregorian.info(wakeUpMoment, Time.FORMAT_SHORT);
        
        // Format hours with leading zero if needed
        var hours = info.hour.format("%02d");
        var mins = info.min.format("%02d");
        
        return Lang.format(timeFormat, [hours, mins]);
    }

    private function formatDuration(totalHours as Float?) as String {
        if (totalHours == null) {
            return _cannotRechargeText;
        }
        if (totalHours <= 0) {
             return _fullText; // Consider it full or requiring negligible time
        }

        var hours = totalHours.toNumber(); // Integer part
        var minutes = Math.round((totalHours - hours) * 60).toNumber();

        // Handle potential rounding up to 60 minutes
        if (minutes >= 60) {
            hours += 1;
            minutes = 0;
        }

        // Ensure minimum displayed time if needed (e.g., 3 hours)?
        // if (hours < 3 && totalHours > 0) {
        //    return "~3h 0m"; 
        // }

        return Lang.format("$1$h $2$m", [hours, minutes.format("%02d")]);
    }


    private function updateUiLabels(dc as Dc, bb as Number?, hr as Number?, rhr as Number?, rate as Float, 
                                   sleepHours as Float?, bbNeeded as Number, wakeUpTime as String) as Void {
        // Barva pro Body Battery
        var bbColor = Graphics.COLOR_WHITE;
        if (bb != null) {
            if (bb >= 80) {
                bbColor = Graphics.COLOR_GREEN;
            } else if (bb >= 40) {
                bbColor = Graphics.COLOR_YELLOW;
            } else {
                bbColor = Graphics.COLOR_RED;
            }
        }
        if (_bodyBatteryValueLabel != null) {
            _bodyBatteryValueLabel.setText(bb != null ? bb.format("%d") : _naText);
            _bodyBatteryValueLabel.setColor(bbColor);
        }
        
        // Barva pro Heart Rate podle vztahu k RHR
        var hrColor = Graphics.COLOR_WHITE;
        if (hr != null && rhr != null) {
            var hrDiff = hr - rhr;
            if (hrDiff <= 5) {
                // HR je blízko klidovému - dobrý stav
                hrColor = Graphics.COLOR_GREEN;
            } else if (hrDiff <= 20) {
                // HR je mírně zvýšené
                hrColor = Graphics.COLOR_YELLOW;
            } else {
                // HR je výrazně zvýšené
                hrColor = Graphics.COLOR_RED;
            }
        }
        
        if (_heartRateValueLabel != null) {
            _heartRateValueLabel.setText(hr != null ? hr.toString() : _naText);
            _heartRateValueLabel.setColor(hrColor);
        }
        
        if (_rhrValueLabel != null) {
            _rhrValueLabel.setText(rhr != null ? rhr.toString() : "--");
        }
        if (_rechargeRateValueLabel != null) {
            _rechargeRateValueLabel.setText(rate.format("%.1f"));
        }
        // Barva a zvýraznění pro výsledek spánku
        var sleepColor = Graphics.COLOR_WHITE;
        if (sleepHours != null) {
            if (sleepHours <= 2) {
                sleepColor = Graphics.COLOR_GREEN;
            } else if (sleepHours <= 5) {
                sleepColor = Graphics.COLOR_YELLOW;
            } else {
                sleepColor = Graphics.COLOR_RED;
            }
        }
        
        if (_estSleepValueLabel != null) {
            if (bb == null) {
                _estSleepValueLabel.setText(_naText);
                _estSleepValueLabel.setColor(Graphics.COLOR_LT_GRAY);
            } else {
                _estSleepValueLabel.setText(formatDuration(sleepHours));
                _estSleepValueLabel.setColor(sleepColor);
                // Krátké bliknutí při změně hodnoty (pouze pokud hodnota není stejná jako předtím)
                if (self._lastSleepValue == null || self._lastSleepValue != sleepHours) {
                    self._lastSleepValue = sleepHours;
                    // Bliknutí: krátce nastavíme barvu na bílou a pak zpět
                    _estSleepValueLabel.setColor(Graphics.COLOR_WHITE);
                    // Toybox.System.sleep(100); // Temporarily commented out due to compilation error
                    _estSleepValueLabel.setColor(sleepColor);
                }
            }
        }
        
        // Zobrazení času probuzení
        if (_wakeUpTimeLabel != null) {
            if (wakeUpTime != "") {
                _wakeUpTimeLabel.setText("@ " + wakeUpTime);
                _wakeUpTimeLabel.setColor(Graphics.COLOR_LT_GRAY);
            } else {
                _wakeUpTimeLabel.setText("");
            }
        }
    }

} 