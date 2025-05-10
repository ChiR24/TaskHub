FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04
FROM cirrusci/flutter:3.22.2

# Set up a working directory
WORKDIR /app

# Copy the project files to the working directory
COPY ../pubspec.yaml ./
COPY ../pubspec.lock ./
COPY ../lib ./lib
COPY ../assets ./assets
# If your background agent needs platform-specific code or assets, copy them here.
# For example:
# COPY ../android ./android
# COPY ../ios ./ios
# COPY ../web ./web
# COPY ../linux ./linux
# COPY ../macos ./macos
# COPY ../windows ./windows

# install.sh and start.sh will be copied and used by the agent configuration
COPY ./install.sh ./install.sh
COPY ./start.sh ./start.sh
RUN chmod +x ./install.sh && chmod +x ./start.sh

# Default command can be overridden by the agent's start script
CMD ["./start.sh"] 