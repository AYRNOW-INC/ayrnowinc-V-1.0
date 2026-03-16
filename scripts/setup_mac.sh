#!/bin/bash
# AYRNOW — Mac Setup Script
# Verifies and installs required dependencies for local development.
# Does NOT use Docker. Does NOT install dangerous/unrelated packages.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "  AYRNOW Mac Setup"
echo "========================================="
echo ""

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Please install:"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi
echo "[OK] Homebrew"

# 2. Git
command -v git &>/dev/null || brew install git
echo "[OK] Git"

# 3. Java 21
if ! [ -d "/opt/homebrew/Cellar/openjdk@21" ]; then
  echo "Installing OpenJDK 21..."
  brew install openjdk@21
fi
export JAVA_HOME="/opt/homebrew/Cellar/openjdk@21/$(ls /opt/homebrew/Cellar/openjdk@21/ | head -1)/libexec/openjdk.jdk/Contents/Home"
echo "[OK] Java 21 at $JAVA_HOME"

# 4. Maven
if ! command -v /opt/homebrew/bin/mvn &>/dev/null; then
  echo "Installing Maven..."
  brew install maven
fi
echo "[OK] Maven"

# 5. PostgreSQL 16
if ! command -v psql &>/dev/null; then
  echo "Installing PostgreSQL 16..."
  brew install postgresql@16
fi
echo "[OK] PostgreSQL"

# Start PostgreSQL
if ! pg_isready -q 2>/dev/null; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 3
fi
echo "[OK] PostgreSQL service running"

# Create database and user
if ! psql -lqt 2>/dev/null | cut -d '|' -f 1 | grep -qw ayrnow; then
  echo "Creating database 'ayrnow'..."
  createdb ayrnow 2>/dev/null || true
  psql postgres -c "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'ayrnow') THEN CREATE ROLE ayrnow WITH LOGIN PASSWORD 'ayrnow'; END IF; END \$\$;" 2>/dev/null
  psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE ayrnow TO ayrnow;" 2>/dev/null
  psql ayrnow -c "GRANT ALL ON SCHEMA public TO ayrnow;" 2>/dev/null
fi
echo "[OK] Database 'ayrnow' ready"

# 6. Flutter
if ! command -v flutter &>/dev/null; then
  echo ""
  echo "Flutter not found. Please install manually:"
  echo "  https://flutter.dev/get-started/install/macos/mobile-ios"
  echo "  After installing, run this script again."
  exit 1
fi
echo "[OK] Flutter $(flutter --version 2>&1 | head -1 | awk '{print $2}')"

# 7. Xcode CLI
if ! xcode-select -p &>/dev/null; then
  echo "Xcode CLI tools not found. Installing..."
  xcode-select --install
  echo "After installation completes, run this script again."
  exit 1
fi
echo "[OK] Xcode CLI tools"

# 8. Copy env examples if needed
cd "$PROJECT_DIR"
if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env 2>/dev/null && echo "[OK] Copied backend/.env.example → backend/.env" || true
fi
if [ ! -f frontend/.env ]; then
  cp frontend/.env.example frontend/.env 2>/dev/null && echo "[OK] Copied frontend/.env.example → frontend/.env" || true
fi

# 9. Build backend
echo ""
echo "Building backend..."
cd "$PROJECT_DIR/backend"
"$JAVA_HOME/bin/java" -version 2>&1 | head -1
/opt/homebrew/bin/mvn package -DskipTests -q
echo "[OK] Backend JAR built"

# 10. Get Flutter dependencies
echo ""
echo "Getting Flutter dependencies..."
cd "$PROJECT_DIR/frontend"
flutter pub get --no-example
echo "[OK] Flutter dependencies ready"

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Edit backend/.env with your API keys (optional for dev)"
echo "  2. Run: ./scripts/run_all_local.sh"
echo "  3. Or run backend and frontend separately:"
echo "     Terminal 1: ./scripts/run_backend.sh"
echo "     Terminal 2: ./scripts/run_frontend.sh"
