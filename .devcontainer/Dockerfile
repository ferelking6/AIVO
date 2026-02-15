# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG FLUTTER_CHANNEL=stable
ARG ANDROID_SDK_API_LEVEL=34
ARG ANDROID_BUILD_TOOLS=34.0.0

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${PATH}:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator"

# -------------------------
# System dependencies
# -------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip libglu1-mesa \
    ca-certificates bash-completion \
    openjdk-17-jdk \
    build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Flutter SDK
# -------------------------
RUN git clone --depth 1 -b ${FLUTTER_CHANNEL} https://github.com/flutter/flutter.git /opt/flutter && \
    /opt/flutter/bin/flutter config --no-analytics && \
    /opt/flutter/bin/flutter precache --android

# -------------------------
# Android SDK (cmdline tools)
# -------------------------
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd /tmp && \
    curl -fsSL -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -q cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm -f cmdline-tools.zip

# Install Android packages + accept licenses
RUN yes | sdkmanager --licenses > /dev/null || true && \
    sdkmanager --install \
      "platform-tools" \
      "platforms;android-${ANDROID_SDK_API_LEVEL}" \
      "build-tools;${ANDROID_BUILD_TOOLS}" \
      "cmdline-tools;latest" \
      "patcher;v4" \
      "emulator" || true

# Fix permissions for vscode user
RUN chown -R vscode:vscode /opt/flutter /opt/android-sdk

USER vscode
WORKDIR /workspaces
