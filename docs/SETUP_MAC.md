# AYRNOW — Mac Setup Guide

## Prerequisites

| Tool | Required Version | Install |
|------|-----------------|---------|
| Homebrew | Latest | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| Java (OpenJDK) | 21 | `brew install openjdk@21` |
| Maven | 3.9+ | `brew install maven` |
| PostgreSQL | 16 | `brew install postgresql@16` |
| Flutter | 3.41+ | See [flutter.dev/get-started](https://flutter.dev/get-started/install/macos/mobile-ios) |
| Xcode | Latest | Mac App Store |
| Xcode CLI Tools | Latest | `xcode-select --install` |
| CocoaPods | 1.16+ | `gem install cocoapods` or comes with Flutter |
| Git | Any | `brew install git` |

## Step-by-Step Setup

### 1. Clone the repo
```bash
git clone git@github.com:ayrnowinc-jpg/AYRNOW-MVP.git
cd AYRNOW-MVP
```

### 2. Run automated setup
```bash
chmod +x scripts/*.sh
./scripts/setup_mac.sh
```

### 3. Or manual setup

#### Java
```bash
brew install openjdk@21
export JAVA_HOME=/opt/homebrew/Cellar/openjdk@21/$(ls /opt/homebrew/Cellar/openjdk@21/)/libexec/openjdk.jdk/Contents/Home
```

#### Maven
```bash
brew install maven
```

#### PostgreSQL
```bash
brew install postgresql@16
brew services start postgresql@16
createdb ayrnow
psql postgres -c "CREATE ROLE ayrnow WITH LOGIN PASSWORD 'ayrnow';"
psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE ayrnow TO ayrnow;"
psql ayrnow -c "GRANT ALL ON SCHEMA public TO ayrnow;"
```

#### Backend
```bash
cd backend
cp .env.example .env  # Edit .env with your values
/opt/homebrew/bin/mvn package -DskipTests
$JAVA_HOME/bin/java -jar target/ayrnow-backend-1.0.0-SNAPSHOT.jar
```
Backend starts on `http://localhost:8080`. Verify: `curl http://localhost:8080/api/health`

#### Frontend
```bash
cd frontend
cp .env.example .env
flutter pub get
flutter run
```

### 4. Verify
```bash
# Health check
curl http://localhost:8080/api/health
# Expected: {"app":"AYRNOW","status":"UP"}

# Register a test user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@ayrnow.com","password":"Test123!","firstName":"Test","lastName":"User","role":"LANDLORD"}'
```

## Important Notes

- **JAVA_HOME must point to JDK 21**, not JDK 25. Maven installed via Homebrew may pull JDK 25 as a dependency — override with `export JAVA_HOME=...` before running Maven/Java.
- **No Docker** — everything runs natively.
- PostgreSQL service must be running before starting the backend.
- Flyway migrations run automatically on backend startup.
