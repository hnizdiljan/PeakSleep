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

// SleepLogic module is expected to be in the same source directory

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
        System.println("🎨 PeakSleepView: Initializing view...");
        View.initialize();
        
        try {
            _naText = WatchUi.loadResource(Rez.Strings.valueNotAvailable) as String;
            _fullText = WatchUi.loadResource(Rez.Strings.valueFull) as String;
            _cannotRechargeText = WatchUi.loadResource(Rez.Strings.valueChargeNotPossible) as String;
            _lastSleepValue = null;
            _updateTimer = null;
            System.println("✅ PeakSleepView: View initialized successfully");
        } catch (ex) {
            System.println("❌ PeakSleepView: Error loading resources: " + ex.getErrorMessage());
            // Fallback hodnoty
            _naText = "N/A";
            _fullText = "Full";
            _cannotRechargeText = "Error";
            _lastSleepValue = null;
            _updateTimer = null;
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        System.println("📐 PeakSleepView: Setting up layout...");
        try {
            setLayout(Rez.Layouts.MainLayout(dc));
            System.println("✅ PeakSleepView: Layout set successfully");

            // Get references to the labels defined in the layout
            _bodyBatteryValueLabel = findDrawableById("bodyBatteryValue") as Text;
            _heartRateValueLabel = findDrawableById("heartRateValue") as Text;
            _estSleepValueLabel = findDrawableById("estSleepValue") as Text;
            _rhrValueLabel = findDrawableById("rhrValue") as Text;
            _rechargeRateValueLabel = findDrawableById("rechargeRateValue") as Text;
            _wakeUpTimeLabel = findDrawableById("wakeUpTime") as Text;
            
            System.println("✅ PeakSleepView: All UI elements found and linked");
        } catch (ex) {
            System.println("❌ PeakSleepView: Error in onLayout: " + ex.getErrorMessage());
            throw ex;
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        System.println("👁️ PeakSleepView: View is being shown...");
        
        // Enable heart rate sensor to make sure we can get current values
        if (Sensor has :setEnabledSensors) {
            System.println("❤️ PeakSleepView: Enabling heart rate sensor");
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        } else {
            System.println("⚠️ PeakSleepView: Cannot enable sensors, method not available");
        }
        
        // Set up timer for periodic updates - méně časté kvůli paměti
        if (_updateTimer == null) {
            System.println("⏰ PeakSleepView: Setting up update timer (15s interval)");
            _updateTimer = new Timer.Timer();
            _updateTimer.start(method(:onTimerTick), 15000, true); // 15 sekund místo 5
            System.println("✅ PeakSleepView: Timer started successfully");
        } else {
            System.println("⏰ PeakSleepView: Timer already running");
        }
        
        System.println("✅ PeakSleepView: onShow completed");
    }
    
    // Timer callback for periodic updates
    function onTimerTick() as Void {
        System.println("⏰ PeakSleepView: Timer tick - requesting UI update");
        WatchUi.requestUpdate();
    }

    // Cache pro snížení počtu náročných volání
    private var _lastRechargeRateUpdate = 0;
    private var _cachedRechargeRate = 8.0f;

    // Update the view
    function onUpdate(dc as Dc) as Void {
        System.println("🎨 PeakSleepView: onUpdate started");
        
        try {
            // Call the parent onUpdate function to draw the layout
            View.onUpdate(dc);
            System.println("✅ PeakSleepView: Parent onUpdate completed");

            // 1. Get Sensor Data (BB, HR, RHR)
            System.println("📊 PeakSleepView: Getting sensor data...");
            var currentBB = SleepLogic.getBodyBattery();
            System.println("🔋 PeakSleepView: Body Battery: " + (currentBB != null ? currentBB.toString() : "null"));
            
            var avgHR = SleepLogic.getAverageHeartRate();
            System.println("❤️ PeakSleepView: Avg HR: " + (avgHR != null ? avgHR.toString() : "null"));
            
            var restingHR = SleepLogic.getRestingHeartRate();
            System.println("😴 PeakSleepView: Resting HR: " + (restingHR != null ? restingHR.toString() : "null"));

            // 2. Get Enhanced Recharge Rate (cached pro snížení memory usage)
            var now = Time.now().value();
            var adjustedRechargeRate = _cachedRechargeRate;
            
            // Aktualizuj recharge rate pouze každých 60 sekund
            if ((now - _lastRechargeRateUpdate) > 60) {
                try {
                    adjustedRechargeRate = SleepLogic.getEnhancedRechargeRate();
                    _cachedRechargeRate = adjustedRechargeRate;
                    _lastRechargeRateUpdate = now;
                    System.println("⚡ PeakSleepView: Recharge rate updated: " + adjustedRechargeRate.format("%.2f"));
                } catch (ex) {
                    System.println("⚠️ PeakSleepView: Error getting recharge rate, using cached value");
                    adjustedRechargeRate = _cachedRechargeRate;
                }
            }

            // 4. Calculate Needed BB
            var bbNeeded = SleepLogic.calculateBbNeeded(currentBB);
            System.println("🎯 PeakSleepView: BB needed: " + bbNeeded);

            // 5. Calculate Sleep Time
            var sleepTimeHours = SleepLogic.calculateSleepTime(bbNeeded, adjustedRechargeRate);
            System.println("⏰ PeakSleepView: Sleep time: " + (sleepTimeHours != null ? sleepTimeHours.format("%.2f") + "h" : "null"));
            
            // 6. Calculate Wake-up Time
            var wakeUpTime = calculateWakeUpTime(sleepTimeHours);
            System.println("🌅 PeakSleepView: Wake up time: " + wakeUpTime);

            // 7. Format and Update UI Labels
            updateUiLabels(dc, currentBB, avgHR, restingHR, adjustedRechargeRate, sleepTimeHours, bbNeeded, wakeUpTime);
            System.println("✅ PeakSleepView: onUpdate completed successfully");
        } catch (ex) {
            System.println("❌ PeakSleepView: Error in onUpdate: " + ex.getErrorMessage());
            // Fallback - zobraz alespoň základní layout
            View.onUpdate(dc);
        }
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