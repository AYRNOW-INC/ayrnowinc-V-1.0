#!/bin/bash
# AyrnowPlanB — Run Frontend
# Starts the PlanB Flutter app on available device/simulator
# IMPORTANT: Requires the AyrnowPlanB backend on port 8080 (not original AYRNOW).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo "  AyrnowPlanB Frontend"
echo "============================================"

# Pre-flight: check backend identity
echo "Checking backend on localhost:8080..."
HEALTH=$(curl -s http://localhost:8080/api/health 2>/dev/null || echo '{}')
REPO=$(echo "$HEALTH" | python3 -c "import sys,json; print(json.load(sys.stdin).get('repo',''))" 2>/dev/null)

if [ -z "$REPO" ]; then
  echo "WARNING: Backend not reachable on port 8080."
  echo "Start it first: cd AyrnowPlanB && ./scripts/run_backend.sh"
  echo ""
elif [ "$REPO" != "AyrnowPlanB" ]; then
  echo ""
  echo "ERROR: Wrong backend running on port 8080!"
  echo "  Expected repo: AyrnowPlanB"
  echo "  Detected repo: $REPO (original AYRNOW?)"
  echo ""
  echo "Kill it and start the PlanB backend:"
  echo "  lsof -ti:8080 | xargs kill -9"
  echo "  cd AyrnowPlanB && ./scripts/run_backend.sh"
  echo ""
  exit 1
else
  echo "Backend OK: repo=$REPO"
fi

cd "$PROJECT_DIR/frontend"

if [ ! -d .dart_tool ]; then
  flutter pub get
fi

echo ""
echo "Starting AyrnowPlanB Flutter app..."
flutter run
