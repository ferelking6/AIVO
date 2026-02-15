#!/usr/bin/env bash
set -euo pipefail

flutter config --no-analytics || true
dart --disable-analytics || true

echo "=== flutter doctor ==="
flutter doctor -v || true

# Auto pub get si pubspec existe
if [ -f "pubspec.yaml" ]; then
  echo "=== flutter pub get ==="
  flutter pub get
fi

echo "✅ Devcontainer ready: Flutter + Android SDK"
