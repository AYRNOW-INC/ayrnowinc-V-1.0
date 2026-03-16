#!/bin/bash
# AyrnowPlanB — Run Backend
# Starts the PlanB Spring Boot backend on port 8080
# IMPORTANT: This is the AyrnowPlanB backend, NOT the original AYRNOW.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo "  AyrnowPlanB Backend"
echo "============================================"

export JAVA_HOME="/opt/homebrew/Cellar/openjdk@21/$(ls /opt/homebrew/Cellar/openjdk@21/ | head -1)/libexec/openjdk.jdk/Contents/Home"

# Kill any existing process on port 8080
if lsof -ti:8080 > /dev/null 2>&1; then
  echo "Killing existing process on port 8080..."
  lsof -ti:8080 | xargs kill -9 2>/dev/null
  sleep 1
fi

# Ensure PostgreSQL is running
if ! pg_isready -q 2>/dev/null; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 2
fi

cd "$PROJECT_DIR/backend"

echo "Building AyrnowPlanB backend..."
/opt/homebrew/bin/mvn package -DskipTests -q

echo ""
echo "Starting AyrnowPlanB backend on http://localhost:8080"
echo "Health: curl http://localhost:8080/api/health"
echo "Expected: repo=AyrnowPlanB, lifecycleEnrichment=true"
echo ""

exec "$JAVA_HOME/bin/java" -jar target/ayrnow-backend-1.0.0-SNAPSHOT.jar
