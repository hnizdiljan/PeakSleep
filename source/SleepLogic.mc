import Toybox.Lang;
import Toybox.System;
import Toybox.Sensor;
import Toybox.SensorHistory;
import Toybox.UserProfile;
import Toybox.Application;
import Toybox.Time; // Keep if calculateWakeUpTime or similar time logic is moved
import Toybox.Time.Gregorian;
import Toybox.Application.Storage;

// Constants BASE_RECHARGE_RATE_KEY and DEFAULT_RECHARGE_RATE 
// are expected to be defined globally (e.g., in PeakSleepApp.mc)

// Konstanty pro historickou analýzu
const SLEEP_ANALYSIS_DAYS = 7;               // Počet dnů pro analýzu
const MIN_SLEEP_DURATION_HOURS = 3;          // Minimální doba spánku pro analýzu
const MAX_SLEEP_DURATION_HOURS = 12;         // Maximální doba spánku pro analýzu
const HISTORICAL_RECHARGE_RATE_KEY = "historicalRechargeRate";
const SLEEP_PATTERNS_KEY = "sleepPatterns";

module SleepLogic {

    // Struktura pro uložení vzorce spánku
    typedef SleepPattern as {
        "startBB" as Number,         // Body Battery na začátku spánku
        "endBB" as Number,           // Body Battery na konci spánku
        "duration" as Float,         // Doba spánku v hodinách
        "rechargeRate" as Float,     // Vypočítaná rychlost regenerace
        "avgStress" as Float,        // Průměrný stres během spánku
        "timestamp" as Number        // Timestamp spánku
    };

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

    // =============== NOVÉ FUNKCE PRO HISTORICKOU ANALÝZU ===============

    function analyzeSleepPatterns() as Array<SleepPattern>? {
        System.println("SleepLogic: Analyzing historical sleep patterns");
        
        if (!((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory))) {
            System.println("SleepLogic: Body battery history not available");
            return null;
        }

        // Získej data za posledních 7 dní
        var weekInSeconds = SLEEP_ANALYSIS_DAYS * 24 * 60 * 60;
        var bbIter = Toybox.SensorHistory.getBodyBatteryHistory({
            :period => weekInSeconds, 
            :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST
        });

        if (bbIter == null) {
            System.println("SleepLogic: No body battery history available");
            return null;
        }

        var sleepPatterns = [] as Array<SleepPattern>;
        var samples = [] as Array<{:data as Number, :when as Time.Moment}>;

        // Načti všechny vzorky
        var sample = bbIter.next();
        while (sample != null) {
            if (sample.data != null && sample.when != null) {
                samples.add({:data => sample.data, :when => sample.when});
            }
            sample = bbIter.next();
        }

        System.println("SleepLogic: Found " + samples.size() + " Body Battery samples");

        // Detekuj periody spánku
        var sleepPeriods = detectSleepPeriods(samples);
        
        // Analyzuj každou periodu spánku
        for (var i = 0; i < sleepPeriods.size(); i++) {
            var period = sleepPeriods[i];
            var pattern = analyzeSingleSleepPeriod(period);
            if (pattern != null) {
                sleepPatterns.add(pattern);
            }
        }

        System.println("SleepLogic: Analyzed " + sleepPatterns.size() + " sleep patterns");
        return sleepPatterns;
    }

    function detectSleepPeriods(samples as Array<{:data as Number, :when as Time.Moment}>) as Array<Array> {
        var sleepPeriods = [] as Array<Array>;
        var currentPeriod = null as Array?;
        var prevBB = null as Number?;
        var prevTime = null as Time.Moment?;

        for (var i = 0; i < samples.size(); i++) {
            var sample = samples[i];
            var bb = sample[:data];
            var time = sample[:when];

            if (prevBB != null && prevTime != null) {
                var timeDiff = time.value() - prevTime.value();
                var bbDiff = bb - prevBB;
                var hoursDiff = timeDiff.toFloat() / 3600.0;

                // Detekce začátku spánku: pokles BB po 21:00 nebo před 06:00
                var timeInfo = Time.Gregorian.info(time, Time.FORMAT_SHORT);
                var isNightTime = timeInfo.hour >= 21 || timeInfo.hour <= 6;
                
                if (bbDiff > 5 && hoursDiff > 0.5 && isNightTime && currentPeriod == null) {
                    // Začátek spánku - BB začíná stoupat
                    currentPeriod = [samples[i-1], sample];
                } else if (currentPeriod != null) {
                    // Pokračování spánku
                    currentPeriod.add(sample);
                    
                    // Konec spánku - BB přestává výrazně stoupat nebo začíná klesat
                    if (bbDiff < 2 && hoursDiff > 0.5) {
                        var duration = (time.value() - currentPeriod[0][:when].value()).toFloat() / 3600.0;
                        if (duration >= MIN_SLEEP_DURATION_HOURS && duration <= MAX_SLEEP_DURATION_HOURS) {
                            sleepPeriods.add(currentPeriod);
                        }
                        currentPeriod = null;
                    }
                }
            }

            prevBB = bb;
            prevTime = time;
        }

        return sleepPeriods;
    }

    function analyzeSingleSleepPeriod(period as Array) as SleepPattern? {
        if (period.size() < 2) {
            return null;
        }

        var startSample = period[0];
        var endSample = period[period.size() - 1];
        
        var startBB = startSample[:data] as Number;
        var endBB = endSample[:data] as Number;
        var startTime = startSample[:when] as Time.Moment;
        var endTime = endSample[:when] as Time.Moment;

        var duration = (endTime.value() - startTime.value()).toFloat() / 3600.0;
        var bbGain = endBB - startBB;

        if (bbGain <= 0 || duration <= 0) {
            return null; // Neplatný spánek
        }

        var rechargeRate = bbGain.toFloat() / duration;
        var avgStress = calculateAverageStressDuringSleep(startTime, endTime);

        return {
            :startBB => startBB,
            :endBB => endBB,
            :duration => duration,
            :rechargeRate => rechargeRate,
            :avgStress => avgStress,
            :timestamp => startTime.value()
        } as SleepPattern;
    }

    function calculateAverageStressDuringSleep(startTime as Time.Moment, endTime as Time.Moment) as Float {
        if (!((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory))) {
            return 0.0f; // Stress history není dostupná
        }

        var duration = endTime.value() - startTime.value();
        var stressIter = Toybox.SensorHistory.getStressHistory({:period => duration});
        
        if (stressIter == null) {
            return 0.0f;
        }

        var sum = 0.0f;
        var count = 0;
        var sample = stressIter.next();
        
        while (sample != null) {
            if (sample.data != null && sample.when != null) {
                var sampleTime = sample.when.value();
                if (sampleTime >= startTime.value() && sampleTime <= endTime.value()) {
                    sum += sample.data.toFloat();
                    count++;
                }
            }
            sample = stressIter.next();
        }

        return count > 0 ? sum / count : 0.0f;
    }

    function calculateHistoricalRechargeRate(patterns as Array<SleepPattern>?) as Float? {
        if (patterns == null || patterns.size() == 0) {
            System.println("SleepLogic: No sleep patterns available for historical analysis");
            return null;
        }

        // Filtruj pouze kvalitní spánky (bez vysokého stresu)
        var validPatterns = [] as Array<SleepPattern>;
        for (var i = 0; i < patterns.size(); i++) {
            var pattern = patterns[i];
            if (pattern[:avgStress] < 70 && pattern[:rechargeRate] > 3 && pattern[:rechargeRate] < 25) {
                validPatterns.add(pattern);
            }
        }

        if (validPatterns.size() == 0) {
            System.println("SleepLogic: No valid sleep patterns found");
            return null;
        }

        // Vážený průměr s důrazem na novější data
        var totalWeight = 0.0f;
        var weightedSum = 0.0f;
        var now = Time.now().value();

        for (var i = 0; i < validPatterns.size(); i++) {
            var pattern = validPatterns[i];
            var ageInDays = (now - pattern[:timestamp]).toFloat() / (24 * 60 * 60);
            // Lineární pokles váhy místo exponenciálního (pro kompatibilitu)
            var weight = ageInDays < 7 ? (7.0f - ageInDays) / 7.0f : 0.1f;
            
            weightedSum += pattern[:rechargeRate] * weight;
            totalWeight += weight;
        }

        var historicalRate = weightedSum / totalWeight;
        System.println("SleepLogic: Historical recharge rate: " + historicalRate.format("%.2f"));
        
        // Ulož výsledek pro cache
        Application.Storage.setValue(HISTORICAL_RECHARGE_RATE_KEY, historicalRate);
        
        return historicalRate;
    }

    function getEnhancedRechargeRate() as Float {
        System.println("SleepLogic: Getting enhanced recharge rate");
        
        // 1. Zkus získat cached historickou rychlost
        var historicalRate = Application.Storage.getValue(HISTORICAL_RECHARGE_RATE_KEY) as Float?;
        var shouldRecalculate = false;
        
        // Přepočítej historickou rychlost jednou denně
        var lastUpdate = Application.Storage.getValue("lastHistoricalUpdate") as Number?;
        var now = Time.now().value();
        if (lastUpdate == null || (now - lastUpdate) > (24 * 60 * 60)) {
            shouldRecalculate = true;
        }

        // 2. Pokud je potřeba, analyzuj historická data
        if (historicalRate == null || shouldRecalculate) {
            System.println("SleepLogic: Recalculating historical recharge rate");
            var patterns = analyzeSleepPatterns();
            historicalRate = calculateHistoricalRechargeRate(patterns);
            Application.Storage.setValue("lastHistoricalUpdate", now);
        }

        // 3. Získej základní rychlost z nastavení
        var baseRate = getBaseRechargeRate();
        
        // 4. Kombinuj historickou a základní rychlost
        var finalRate = baseRate;
        if (historicalRate != null) {
            // Vážený průměr: 70% historická, 30% nastavená
            finalRate = (historicalRate * 0.7f) + (baseRate * 0.3f);
            System.println("SleepLogic: Combined rate - Historical: " + historicalRate.format("%.2f") + 
                          ", Base: " + baseRate.format("%.2f") + ", Final: " + finalRate.format("%.2f"));
        } else {
            System.println("SleepLogic: Using base rate only: " + baseRate.format("%.2f"));
        }

        // 5. Aplikuj aktuální stresovou úpravu
        var currentHR = getAverageHeartRate();
        var restingHR = getRestingHeartRate();
        var adjustedRate = calculateAdjustedRechargeRate(finalRate, currentHR, restingHR);

        System.println("SleepLogic: Enhanced recharge rate: " + adjustedRate.format("%.2f"));
        return adjustedRate;
    }

    // Funkce pro vymazání cached dat (pro testování)
    function clearHistoricalData() as Void {
        Application.Storage.deleteValue(HISTORICAL_RECHARGE_RATE_KEY);
        Application.Storage.deleteValue("lastHistoricalUpdate");
        Application.Storage.deleteValue(SLEEP_PATTERNS_KEY);
        System.println("SleepLogic: Historical data cleared");
    }

    // Získej statistiky o historické analýze
    function getHistoricalAnalysisStats() as Dictionary? {
        var historicalRate = Application.Storage.getValue(HISTORICAL_RECHARGE_RATE_KEY) as Float?;
        var lastUpdate = Application.Storage.getValue("lastHistoricalUpdate") as Number?;
        
        if (historicalRate == null) {
            return null;
        }

        var now = Time.now().value();
        var daysSinceUpdate = lastUpdate != null ? (now - lastUpdate).toFloat() / (24 * 60 * 60) : -1;

        return {
            :historicalRate => historicalRate,
            :daysSinceUpdate => daysSinceUpdate,
            :baseRate => getBaseRechargeRate(),
            :hasHistoricalData => true
        };
    }
} 