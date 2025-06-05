# Peak Sleep

## Overview
Peak Sleep is a Garmin Connect IQ widget that helps you determine how much sleep you need to fully recharge your Body Battery. The application uses your current Body Battery level, heart rate, and resting heart rate to estimate the amount of sleep needed to reach a 100% Body Battery. It also provides a Bedtime Advisor to help you find the ideal time to go to bed based on your desired wake-up time and physiological state.

## Features
- **Current Metrics Display**: Shows your current Body Battery level, heart rate, and resting heart rate
- **Sleep Time Estimation**: Calculates how many hours and minutes of sleep you need to fully recharge
- **Personalized Calculations**: Takes into account your resting heart rate (RHR) and current heart rate to adjust sleep estimates
- **Customizable Recharge Rate**: Allows you to set your personal Body Battery recharge rate through app settings
- **Bedtime Advisor**: Suggests the ideal time to go to bed to achieve full recharge by your chosen wake-up time
- **Color-coded UI**: Key values are color-coded for quick status recognition (green/yellow/red)

## How It Works
1. The widget reads your current Body Battery level from your Garmin device
2. It calculates how many Body Battery points you need to reach 100%
3. Based on your configured recharge rate and current physiological state (heart rate vs. resting heart rate), it estimates the sleep time needed
4. The Bedtime Advisor view uses your desired wake-up time and calculates when you should go to bed to achieve full recharge
5. The estimate is displayed in hours and minutes, with additional prompts if it's too late for a full recharge

## App Screens
- **Peak Sleep View**: Shows your current Body Battery, heart rate, resting heart rate, recharge rate, estimated sleep needed, and projected wake-up time if you go to sleep now.
- **Bedtime Advisor View**: Shows your set wake-up time, required sleep duration, ideal bedtime, and a countdown or prompt (e.g., "Go to sleep in: 1h 20m" or "Too late for full recharge!").

**Note**: Historical stats and daily sleep statistics were removed to simplify the app and avoid Garmin SDK bugs with `getBodyBatteryHistory()` API.

## Settings
- **Recharge Rate**: Adjust the base recharge rate (points per hour) through the Connect IQ app settings. Default is 11.0 points per hour. Range: 1–30.
- **Wake-up Time**: Set your desired wake-up hour (0–23) and minute (0–59) in the app settings. The Bedtime Advisor uses this to recommend when to go to bed.

## Supported Devices
The app is compatible with most Garmin devices that support Connect IQ 3.0 and higher and have Body Battery functionality, including:
- Fenix 6/7/8 series (all variants)
- Forerunner 245, 645, 745, 935, 945, 945 LTE, 955, 965
- Venu, Venu 2
- Vivoactive 4, 4S, 5, 6
- And other compatible devices (see manifest.xml for full list)

## Permissions
The app requires the following permissions:
- **Sensor**: To access real-time heart rate data
- **SensorHistory**: To access historical heart rate and Body Battery data
- **UserProfile**: To access resting heart rate and fallback Body Battery values

## Languages
- English (default)

## Installation
1. Download the app from the Garmin Connect IQ Store
2. Sync your device with Garmin Connect
3. The widget will appear in your widgets list on your device

## Tips for Use
- Check the widget before bed to know how much sleep you need
- Use the Bedtime Advisor to plan your bedtime for optimal recharge
- The estimated sleep time adjusts based on your current heart rate relative to your resting heart rate
- If your Body Battery is already at 100%, the widget will display "Full"
- If Body Battery data is unavailable, the widget will display "N/A"
- If it's too late to fully recharge before your wake-up time, the Bedtime Advisor will notify you

## User Interface
- The main view displays all key metrics in a clear, color-coded format
- The Bedtime Advisor view provides actionable prompts and countdowns
- All labels and prompts are in English

## Logic Details
- **Body Battery** is read from SensorHistory, UserProfile, or directly from the device (with fallbacks)
- **Average Heart Rate** is calculated from the last 2 hours of history, or current value if unavailable
- **Resting Heart Rate** is estimated from the lowest value in the last 24 hours, or from the user profile
- **Recharge Rate** can be customized; if your heart rate is elevated above resting, the recharge rate is reduced
- **Sleep Needed** = (100 - current Body Battery) / recharge rate (adjusted for stress)
- **Bedtime Calculation**: Uses your set wake-up time and required sleep to recommend when to go to bed

For more details, see the source code and manifest.xml for device compatibility and permissions. 