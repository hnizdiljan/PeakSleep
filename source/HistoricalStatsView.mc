import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

class HistoricalStatsView extends WatchUi.View {

    private var _titleLabel as Text?;
    private var _historicalRateLabel as Text?;
    private var _historicalRateValueLabel as Text?;
    private var _baseRateLabel as Text?;
    private var _baseRateValueLabel as Text?;
    private var _lastUpdateLabel as Text?;
    private var _lastUpdateValueLabel as Text?;
    private var _statusLabel as Text?;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Prozatím použiju základní layout, dokud nevytvořím specifický
        setLayout(Rez.Layouts.MainLayout(dc));

        // Pro nyní použiju existující labely (budou přepsány obsahem)
        _titleLabel = findDrawableById("bodyBatteryValue") as Text?;
        _historicalRateLabel = findDrawableById("heartRateValue") as Text?;
        _historicalRateValueLabel = findDrawableById("estSleepValue") as Text?;
        _baseRateLabel = findDrawableById("rhrValue") as Text?;
        _baseRateValueLabel = findDrawableById("rechargeRateValue") as Text?;
        _lastUpdateLabel = findDrawableById("wakeUpTime") as Text?;
        _lastUpdateValueLabel = null; // Nepoužito
        _statusLabel = null; // Nepoužito
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        // Získej statistiky historické analýzy
        var stats = SleepLogic.getHistoricalAnalysisStats();
        
        if (stats != null) {
            updateWithStats(stats);
        } else {
            updateWithoutStats();
        }
    }

    function onHide() as Void {
    }

    private function updateWithStats(stats as Dictionary) as Void {
        if (_titleLabel != null) {
            _titleLabel.setText("Historická analýza");
        }

        if (_historicalRateLabel != null) {
            _historicalRateLabel.setText("Historická rychlost:");
        }

        if (_historicalRateValueLabel != null) {
            var historicalRate = stats[:historicalRate] as Float;
            _historicalRateValueLabel.setText(historicalRate.format("%.1f") + " BB/h");
            _historicalRateValueLabel.setColor(Graphics.COLOR_GREEN);
        }

        if (_baseRateLabel != null) {
            _baseRateLabel.setText("Nastavená rychlost:");
        }

        if (_baseRateValueLabel != null) {
            var baseRate = stats[:baseRate] as Float;
            _baseRateValueLabel.setText(baseRate.format("%.1f") + " BB/h");
            _baseRateValueLabel.setColor(Graphics.COLOR_WHITE);
        }

        if (_lastUpdateLabel != null) {
            _lastUpdateLabel.setText("Poslední analýza:");
        }

        if (_lastUpdateValueLabel != null) {
            var daysSinceUpdate = stats[:daysSinceUpdate] as Float;
            var updateText = "";
            
            if (daysSinceUpdate < 0) {
                updateText = "Neznámo";
            } else if (daysSinceUpdate < 1) {
                updateText = "Dnes";
            } else if (daysSinceUpdate < 2) {
                updateText = "Včera";
            } else {
                updateText = daysSinceUpdate.format("%.0f") + " dní";
            }
            
            _lastUpdateValueLabel.setText(updateText);
            
            // Barva podle stáří dat
            if (daysSinceUpdate < 1) {
                _lastUpdateValueLabel.setColor(Graphics.COLOR_GREEN);
            } else if (daysSinceUpdate < 3) {
                _lastUpdateValueLabel.setColor(Graphics.COLOR_YELLOW);
            } else {
                _lastUpdateValueLabel.setColor(Graphics.COLOR_RED);
            }
        }

        if (_statusLabel != null) {
            _statusLabel.setText("✓ Historická data dostupná");
            _statusLabel.setColor(Graphics.COLOR_GREEN);
        }
    }

    private function updateWithoutStats() as Void {
        if (_titleLabel != null) {
            _titleLabel.setText("Historická analýza");
        }

        if (_historicalRateLabel != null) {
            _historicalRateLabel.setText("Historická rychlost:");
        }

        if (_historicalRateValueLabel != null) {
            _historicalRateValueLabel.setText("Nedostupná");
            _historicalRateValueLabel.setColor(Graphics.COLOR_LT_GRAY);
        }

        if (_baseRateLabel != null) {
            _baseRateLabel.setText("Nastavená rychlost:");
        }

        if (_baseRateValueLabel != null) {
            var baseRate = SleepLogic.getBaseRechargeRate();
            _baseRateValueLabel.setText(baseRate.format("%.1f") + " BB/h");
            _baseRateValueLabel.setColor(Graphics.COLOR_WHITE);
        }

        if (_lastUpdateLabel != null) {
            _lastUpdateLabel.setText("Poslední analýza:");
        }

        if (_lastUpdateValueLabel != null) {
            _lastUpdateValueLabel.setText("Nikdy");
            _lastUpdateValueLabel.setColor(Graphics.COLOR_LT_GRAY);
        }

        if (_statusLabel != null) {
            _statusLabel.setText("⚠ Shromažďuji data...");
            _statusLabel.setColor(Graphics.COLOR_YELLOW);
        }
    }
} 