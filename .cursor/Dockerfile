FROM cirrusci/flutter:3.22.2

# Set the working directory.
# The platform is expected to clone your repository into this directory.
WORKDIR /app

# The Flutter SDK is included in the base image.
# Application code will be checked out by the platform.
# Install and Start scripts will be provided via the UI fields and run by the platform.
# Ensure this Dockerfile is in the .cursor directory and the build context in environment.json is "."

# install.sh and start.sh will be copied and used by the agent configuration
COPY ./install.sh ./install.sh
COPY ./start.sh ./start.sh
RUN chmod +x ./install.sh && chmod +x ./start.sh

# Default command can be overridden by the agent's start script
CMD ["./start.sh"]