#!/bin/bash
# AYRNOW — Run Frontend
# Starts Flutter app on available device/simulator

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR/frontend"

# Get dependencies if needed
if [ ! -d .dart_tool ]; then
  flutter pub get
fi

echo "Starting AYRNOW Flutter app..."
echo "Make sure the backend is running on localhost:8080"
echo ""

flutter run
