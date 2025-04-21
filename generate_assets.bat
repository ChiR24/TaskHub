@echo off
echo Generating app icons and splash screen...

REM Install dependencies
call flutter pub get

REM Generate app icons
call flutter pub run flutter_launcher_icons

REM Generate splash screen
call flutter pub run flutter_native_splash:create

echo Assets generation complete!
pause
