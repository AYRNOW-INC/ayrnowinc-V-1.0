#!/bin/bash
# AYRNOW — Dependency Checker
# Verifies all required tools are installed and at correct versions.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check() {
  local name="$1"
  local cmd="$2"
  local expected="$3"

  if command -v "$cmd" &>/dev/null; then
    local version
    version=$($cmd --version 2>&1 | head -1 || echo "unknown")
    echo -e "${GREEN}[PASS]${NC} $name — $version"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}[FAIL]${NC} $name — not found. Install: $expected"
    FAIL=$((FAIL + 1))
  fi
}

check_service() {
  local name="$1"
  local check_cmd="$2"
  local fix="$3"

  if eval "$check_cmd" &>/dev/null; then
    echo -e "${GREEN}[PASS]${NC} $name — running"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}[WARN]${NC} $name — not running. Fix: $fix"
    WARN=$((WARN + 1))
  fi
}

echo "========================================="
echo "  AYRNOW Dependency Check"
echo "========================================="
echo ""

echo "--- Build Tools ---"
check "Homebrew" "brew" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
check "Git" "git" "brew install git"
check "Maven" "/opt/homebrew/bin/mvn" "brew install maven"

echo ""
echo "--- Languages & Runtimes ---"
check "Java" "java" "brew install openjdk@21"

# Check Java version is 21
JAVA_VER=$(java -version 2>&1 | head -1 | grep -oE '"[0-9]+' | tr -d '"')
if [ "$JAVA_VER" = "21" ]; then
  echo -e "${GREEN}[PASS]${NC} Java version 21 confirmed"
  PASS=$((PASS + 1))
elif [ -d "/opt/homebrew/Cellar/openjdk@21" ]; then
  echo -e "${YELLOW}[WARN]${NC} Java $JAVA_VER active but JDK 21 installed. Set JAVA_HOME to JDK 21."
  WARN=$((WARN + 1))
else
  echo -e "${RED}[FAIL]${NC} Java 21 required. Install: brew install openjdk@21"
  FAIL=$((FAIL + 1))
fi

check "Flutter" "flutter" "See https://flutter.dev/get-started/install"

echo ""
echo "--- Database ---"
check "PostgreSQL" "psql" "brew install postgresql@16"
check_service "PostgreSQL service" "pg_isready -q" "brew services start postgresql@16"

# Check ayrnow database exists
if psql -lqt 2>/dev/null | cut -d '|' -f 1 | grep -qw ayrnow; then
  echo -e "${GREEN}[PASS]${NC} Database 'ayrnow' exists"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}[WARN]${NC} Database 'ayrnow' not found. Run: createdb ayrnow"
  WARN=$((WARN + 1))
fi

echo ""
echo "--- iOS Development ---"
if xcode-select -p &>/dev/null; then
  echo -e "${GREEN}[PASS]${NC} Xcode CLI tools installed"
  PASS=$((PASS + 1))
else
  echo -e "${RED}[FAIL]${NC} Xcode CLI tools missing. Run: xcode-select --install"
  FAIL=$((FAIL + 1))
fi

if xcrun simctl list devices available 2>/dev/null | grep -qi "iphone"; then
  echo -e "${GREEN}[PASS]${NC} iOS simulators available"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}[WARN]${NC} No iOS simulators found. Open Xcode to download simulators."
  WARN=$((WARN + 1))
fi

echo ""
echo "--- Project Files ---"
for f in backend/pom.xml frontend/pubspec.yaml backend/.env.example frontend/.env.example; do
  if [ -f "$f" ]; then
    echo -e "${GREEN}[PASS]${NC} $f exists"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}[WARN]${NC} $f missing"
    WARN=$((WARN + 1))
  fi
done

echo ""
echo "========================================="
echo -e "  Results: ${GREEN}$PASS passed${NC}, ${YELLOW}$WARN warnings${NC}, ${RED}$FAIL failed${NC}"
echo "========================================="

if [ $FAIL -gt 0 ]; then
  echo -e "${RED}Fix the failures above before proceeding.${NC}"
  exit 1
fi
