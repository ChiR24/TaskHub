@echo off
echo Generating app icons...

REM Run the icon generator app
flutter run -d windows lib/icon_generator_app.dart

echo Icons generated! Now generating app assets...

REM Generate app icons
flutter pub run flutter_launcher_icons

REM Generate splash screen
flutter pub run flutter_native_splash:create

echo Asset generation complete!
pause
