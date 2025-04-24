FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install necessary packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    default-jdk-headless \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter
ARG FLUTTER_VERSION=stable
ENV FLUTTER_ROOT=/usr/local/flutter
ENV PATH=$FLUTTER_ROOT/bin:$PATH

RUN git clone -b $FLUTTER_VERSION https://github.com/flutter/flutter.git $FLUTTER_ROOT && \
    flutter config --no-analytics

# Pre-download common Flutter artifacts
RUN flutter precache 