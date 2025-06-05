// Test script pro ověření Enhanced Recharge Rate implementace
// Tento soubor slouží pouze pro testování - není součástí finální aplikace

import Toybox.System;
import Toybox.Lang;

// Simulované testovací funkce
function testEnhancedRechargeRate() as Void {
    System.println("=== Test Enhanced Recharge Rate ===");
    
    // Test 1: Základní výpočet bez historických dat
    System.println("Test 1: Základní výpočet (bez historie)");
    SleepLogic.clearHistoricalData(); // Vymaž cache
    var rate1 = SleepLogic.getEnhancedRechargeRate();
    System.println("Expected: ~11.0, Actual: " + rate1.format("%.2f"));
    
    // Test 2: Statistiky historické analýzy (bez dat)
    System.println("Test 2: Statistiky (bez dat)");
    var stats1 = SleepLogic.getHistoricalAnalysisStats();
    System.println("Expected: null, Actual: " + (stats1 == null ? "null" : "data"));
    
    // Test 3: Analýza spánkových vzorců
    System.println("Test 3: Analýza historických dat");
    var patterns = SleepLogic.analyzeSleepPatterns();
    System.println("Sleep patterns found: " + (patterns != null ? patterns.size() : 0));
    
    // Test 4: Enhanced recharge rate s případnými historickými daty
    System.println("Test 4: Enhanced rate s případnými daty");
    var rate2 = SleepLogic.getEnhancedRechargeRate();
    System.println("Enhanced rate: " + rate2.format("%.2f"));
    
    // Test 5: Statistiky po analýze
    System.println("Test 5: Statistiky po analýze");
    var stats2 = SleepLogic.getHistoricalAnalysisStats();
    if (stats2 != null) {
        System.println("Historical rate: " + stats2[:historicalRate].format("%.2f"));
        System.println("Base rate: " + stats2[:baseRate].format("%.2f"));
        System.println("Days since update: " + stats2[:daysSinceUpdate].format("%.1f"));
    }
    
    System.println("=== Test Complete ===");
}

// Funkce pro testování detekce spánkových období
function testSleepDetection() as Void {
    System.println("=== Test Sleep Detection ===");
    
    // Simulace BB dat (normálně by byly z SensorHistory)
    var testSamples = [
        // Simulace večerního poklesu a nočního vzestupu BB
        // Format: {:data => BB_value, :when => simulated_time}
    ];
    
    System.println("Sleep detection test completed");
    System.println("Note: Real data from SensorHistory needed for full test");
    System.println("=== Test Complete ===");
}

// Main test function - volej z onUpdate() pro testování
function runAllTests() as Void {
    System.println("Starting Enhanced Recharge Rate Tests...");
    testEnhancedRechargeRate();
    testSleepDetection();
    System.println("All tests completed!");
} 