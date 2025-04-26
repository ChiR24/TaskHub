FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Add necessary arguments for non-interactive installs
ARG DEBIAN_FRONTEND=noninteractive

# Avoid prompts from apt
ENV apt_opts="-y --no-install-recommends"

# Install basic dependencies needed for Flutter setup and general development
RUN apt-get update && apt-get install $apt_opts \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Set up a non-root user (vscode)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    apt-get update && apt-get install $apt_opts sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to non-root user
USER $USERNAME

# --- Flutter Installation ---\
# Define Flutter version
ARG FLUTTER_VERSION=3.22.2
ENV FLUTTER_HOME=/home/$USERNAME/flutter
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:${PATH}"

# Download and install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch $FLUTTER_VERSION $FLUTTER_HOME && \
    # Run flutter doctor to download Dart SDK and other dependencies
    flutter doctor && \
    # Grant execution permissions
    chmod -R +x $FLUTTER_HOME/bin

# Accept licenses (optional, but can prevent prompts later)
# RUN yes | flutter doctor --android-licenses

# --- End Flutter Installation ---\

# Set working directory
WORKDIR /workspaces

# Clean up
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* 