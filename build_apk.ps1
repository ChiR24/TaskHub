Write-Host "Changing to project directory..."
Set-Location "X:\GitHub\Mini TaskHub\mini_taskhub"

Write-Host "Cleaning project..."
flutter clean

Write-Host "Getting dependencies..."
flutter pub get

Write-Host "Building release APK..."
flutter build apk --release

Write-Host "Done!"
