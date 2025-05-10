import Toybox.Lang;
import Toybox.System;
import Toybox.Sensor;
import Toybox.SensorHistory;
import Toybox.UserProfile;
import Toybox.Application;
import Toybox.Time; // Keep if calculateWakeUpTime or similar time logic is moved

// Constants BASE_RECHARGE_RATE_KEY and DEFAULT_RECHARGE_RATE 
// are expected to be defined globally (e.g., in PeakSleepApp.mc)

module SleepLogic {

    function getBodyBattery() as Number? {
        // Copied from PeakSleepView.mc (the more complete version)
        System.println("SleepLogic: getBodyBattery() called");
        
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            System.println("SleepLogic: Using SensorHistory.getBodyBatteryHistory");
            var bbIter = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            if (bbIter != null) {
                var sample = bbIter.next();
                if (sample != null && sample.data != null) {
                    System.println("SleepLogic: Returning BB from SensorHistory: " + sample.data);
                    return sample.data;
                } else {
                    System.println("SleepLogic: Sample or sample.data is null from SensorHistory");
                }
            } else {
                System.println("SleepLogic: bbIter is null from SensorHistory");
            }
        } else {
            System.println("SleepLogic: SensorHistory method not available");
        }
        
        if ((UserProfile has :getBodyBatteryHistory)) {
            System.println("SleepLogic: Using UserProfile.getBodyBatteryHistory");
            var bbIterator = UserProfile.getBodyBatteryHistory({:period=>1});
            if (bbIterator != null) {
                 var sample = bbIterator.next();
                 if (sample != null && sample.data != null) {
                     System.println("SleepLogic: Returning BB from history: " + sample.data);
                     return sample.data;
                 } else {
                     System.println("SleepLogic: Sample or sample.data is null from history");
                 }
            } else {
                System.println("SleepLogic: bbIterator is null");
            }
        } else {
            System.println("SleepLogic: UserProfile has no :getBodyBatteryHistory");
        }
        
        if ((UserProfile has :getBodyBattery)) {
             System.println("SleepLogic: Using UserProfile.getBodyBattery");
             var bbDirect = UserProfile.getBodyBattery();
             if (bbDirect != null) {
                 System.println("SleepLogic: Returning BB direct: " + bbDirect);
                 return bbDirect;
             } else {
                System.println("SleepLogic: bbDirect is null");
             }
        } else {
            System.println("SleepLogic: UserProfile has no :getBodyBattery");
        }
        
        System.println("SleepLogic: getBodyBattery() returning null");
        return null;
    }

    function getAverageHeartRate() as Number? {
        // Copied from PeakSleepView.mc
        System.println("SleepLogic: getAverageHeartRate() called");
        
        if (Sensor has :setEnabledSensors) {
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        }
        
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
            var twoHoursInSeconds = 2 * 60 * 60;
            var hrIter = Toybox.SensorHistory.getHeartRateHistory({:period => twoHoursInSeconds});
            
            if (hrIter != null) {
                var sum = 0;
                var count = 0;
                var sample = hrIter.next();
                while (sample != null) {
                    if (sample.data != null && sample.data > 0) {
                        sum += sample.data;
                        count++;
                    }
                    sample = hrIter.next();
                }
                
                if (count > 0) {
                    System.println("SleepLogic: Returning average HR from " + count + " samples: " + (sum / count));
                    return (sum.toFloat() / count).toNumber(); // Ensure float division before toNumber
                }
            }
        }
        
        System.println("SleepLogic: Falling back to current HR for average");
        var sensorInfo = Sensor.getInfo();
        if (sensorInfo != null && (sensorInfo has :currentHeartRate) && sensorInfo.currentHeartRate != null) {
            return sensorInfo.currentHeartRate;
        }
        
        return null;
    }

    function getRestingHeartRate() as Number? {
        // Copied from PeakSleepView.mc
        System.println("SleepLogic: getRestingHeartRate() called");
        
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
            System.println("SleepLogic: Trying to estimate RHR from heart rate history");
            var oneDayInSeconds = 24 * 60 * 60;
            var hrIter = Toybox.SensorHistory.getHeartRateHistory({:period => oneDayInSeconds});
            
            if (hrIter != null) {
                var minHR = null;
                var sample = hrIter.next();
                while (sample != null) {
                    if (sample.data != null && sample.data > 30) {
                        if (minHR == null || sample.data < minHR) {
                            minHR = sample.data;
                        }
                    }
                    sample = hrIter.next();
                }
                
                if (minHR != null) {
                    System.println("SleepLogic: Estimated RHR from history minimum: " + minHR);
                    return minHR;
                }
            }
        }
        
        var profile = UserProfile.getProfile();
        if (profile != null && profile.restingHeartRate != null) {
            System.println("SleepLogic: Returning RHR from profile: " + profile.restingHeartRate);
            return profile.restingHeartRate;
        }
        
        return null;
    }

    function getBaseRechargeRate() as Float {
        // Uses global constants BASE_RECHARGE_RATE_KEY and DEFAULT_RECHARGE_RATE
        var rate = Application.Properties.getValue(BASE_RECHARGE_RATE_KEY); 
        if (rate instanceof Number) {
            return rate.toFloat();
        }
        if (rate instanceof Float) {
            return rate;
        }
        return DEFAULT_RECHARGE_RATE;
    }

    function calculateAdjustedRechargeRate(baseRate as Float, hr as Number?, rhr as Number?) as Float {
        // Copied from PeakSleepView.mc
        if (hr != null && rhr != null && hr > rhr + 5) { 
            var stressFactor = hr - rhr - 5;
            var adjusted = baseRate * (1.0 - (stressFactor * 0.01));
            var minRate = baseRate * 0.5;
            return adjusted > minRate ? adjusted : minRate;
        } 
        return baseRate;
    }

    function calculateBbNeeded(currentBB as Number?) as Number {
        // Copied from PeakSleepView.mc
        if (currentBB == null) {
            return 100;
        }
        if (currentBB >= 100) {
            return 0;
        }
        return 100 - currentBB;
    }

    function calculateSleepTime(bbNeeded as Number, rechargeRate as Float) as Float? {
        // Copied from PeakSleepView.mc
        if (rechargeRate <= 0) {
            return null; 
        }
        if (bbNeeded <= 0) {
            return 0.0f;
        }
        return bbNeeded.toFloat() / rechargeRate; // Ensure float division
    }
} 