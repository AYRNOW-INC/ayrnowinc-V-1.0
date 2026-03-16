#!/bin/bash
# AYRNOW — Run All Services Locally
# Starts PostgreSQL, backend, and opens frontend

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

export JAVA_HOME="/opt/homebrew/Cellar/openjdk@21/$(ls /opt/homebrew/Cellar/openjdk@21/ | head -1)/libexec/openjdk.jdk/Contents/Home"

echo "========================================="
echo "  AYRNOW — Starting All Services"
echo "========================================="

# 1. PostgreSQL
if ! pg_isready -q 2>/dev/null; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 2
fi
echo "[OK] PostgreSQL running"

# 2. Backend (background)
cd "$PROJECT_DIR/backend"
if [ ! -f target/ayrnow-backend-1.0.0-SNAPSHOT.jar ]; then
  echo "Building backend..."
  /opt/homebrew/bin/mvn package -DskipTests -q
fi

echo "Starting backend..."
"$JAVA_HOME/bin/java" -jar target/ayrnow-backend-1.0.0-SNAPSHOT.jar &
BACKEND_PID=$!
sleep 5

# Verify backend
if curl -s http://localhost:8080/api/health | grep -q "UP"; then
  echo "[OK] Backend running on http://localhost:8080 (PID: $BACKEND_PID)"
else
  echo "[ERROR] Backend failed to start"
  kill $BACKEND_PID 2>/dev/null
  exit 1
fi

# 3. Frontend
cd "$PROJECT_DIR/frontend"
if [ ! -d .dart_tool ]; then
  flutter pub get
fi

echo ""
echo "========================================="
echo "  Backend running (PID: $BACKEND_PID)"
echo "  Starting Flutter frontend..."
echo "  Press Ctrl+C to stop all services"
echo "========================================="
echo ""

# Trap to kill backend when frontend exits
trap "kill $BACKEND_PID 2>/dev/null; echo 'Services stopped.'" EXIT

flutter run
