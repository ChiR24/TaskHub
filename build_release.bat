@echo off
echo Cleaning project...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building release APK...
flutter build apk --release

echo Done!
pause
