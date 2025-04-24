#!/bin/bash
set -e

# Setup Flutter environment
flutter --version

# Accept Android licenses
yes | flutter doctor --android-licenses || true

# Download dependencies
flutter pub get

# Run any custom post-update steps here
echo "Flutter environment is ready!" 