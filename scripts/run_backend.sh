#!/bin/bash
# AYRNOW — Run Backend
# Starts Spring Boot on port 8080

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

export JAVA_HOME="/opt/homebrew/Cellar/openjdk@21/$(ls /opt/homebrew/Cellar/openjdk@21/ | head -1)/libexec/openjdk.jdk/Contents/Home"

# Ensure PostgreSQL is running
if ! pg_isready -q 2>/dev/null; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 2
fi

cd "$PROJECT_DIR/backend"

# Build if JAR doesn't exist
if [ ! -f target/ayrnow-backend-1.0.0-SNAPSHOT.jar ]; then
  echo "Building backend..."
  /opt/homebrew/bin/mvn package -DskipTests -q
fi

echo "Starting AYRNOW backend on http://localhost:8080"
echo "Health check: curl http://localhost:8080/api/health"
echo ""

exec "$JAVA_HOME/bin/java" -jar target/ayrnow-backend-1.0.0-SNAPSHOT.jar
