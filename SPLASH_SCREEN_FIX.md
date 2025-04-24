# Splash Screen Fix

This document explains the changes made to fix the double splash screen issue in the DayTask app.

## Changes Made

1. **Removed Native Splash Screen**:
   - Modified Android styles to use a transparent background
   - Removed the SplashScreenDrawable meta-data from AndroidManifest.xml
   - Simplified the launch_background.xml files

2. **URL Launcher Warnings**:
   - The url_launcher warnings are coming from Supabase which uses it as a transitive dependency
   - These warnings can be safely ignored as they don't affect the app's functionality

## How to Run the App

To run the app with the fixed splash screen:

1. **Clean the project**:
   ```
   flutter clean
   ```

2. **Get dependencies**:
   ```
   flutter pub get
   ```

3. **Run the app**:
   ```
   flutter run -d <device-id>
   ```
   
   For example:
   ```
   flutter run -d emulator-5554
   ```

4. **If you still see two splash screens**:
   - Uninstall the app from your device/emulator
   - Run the app again with `flutter run -d <device-id>`

## Troubleshooting

If you encounter any issues:

1. **Check the Android emulator version**:
   - Some older Android emulators might still show a brief native splash screen
   - Try using a newer Android emulator version

2. **Verify the changes**:
   - Make sure the styles.xml files have been updated to use a transparent background
   - Confirm that the AndroidManifest.xml no longer references the SplashScreenDrawable

3. **Additional options**:
   - You can try adding `android:windowDisablePreview="true"` to the NormalTheme style
   - This will completely disable any preview window before the Flutter UI is drawn
