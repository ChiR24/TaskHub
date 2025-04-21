@echo off
echo Building DayTask v0.1.0 release...

echo Building Web...
flutter build web --release

echo Building Android APK...
flutter build apk --release

echo Creating release directory...
mkdir -p release

echo Copying builds to release directory...
xcopy /E /I /Y build\web release\web
copy build\app\outputs\flutter-apk\app-release.apk release\daytask-v0.1.0.apk

echo Release build complete!
echo Web build: release\web
echo Android APK: release\daytask-v0.1.0.apk
