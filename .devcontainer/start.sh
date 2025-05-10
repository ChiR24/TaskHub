#!/bin/bash
set -e

echo "Starting Flutter application..."
# Run the Flutter application.
# Add any specific flags your application might need for a headless/background environment.
# For example, if your app is a web server, you might use: flutter run -d web-server --web-port=8080
# Or for a general Flutter app, often no extra flags are needed unless you encounter issues.
flutter run --no-sound-null-safety

echo "Application exited." 