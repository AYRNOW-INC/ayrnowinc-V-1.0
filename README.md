# AYRNOW MVP

**Landlord-Tenant Property Management & Rent Collection Platform**

AYRNOW simplifies rental operations for homeowners and landlords with guided, mobile-friendly workflows — from property setup through lease signing to rent collection.

## Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | Flutter | 3.41.4 |
| Backend | Spring Boot | 3.4.4 |
| Database | PostgreSQL | 16 |
| Migrations | Flyway | Managed by Spring Boot |
| Language (backend) | Java | 21 |
| Architecture | Monolith | — |
| Docker | **Not used** | — |

## External Integrations

| Service | Purpose | Status |
|---------|---------|--------|
| Native Auth | Auth (login, register, JWT tokens) | Built — social OAuth deferred |
| OpenSign | Lease e-signing | Planned — stubs built |
| Stripe | Rent payment processing | Checkout + webhook built |

## Quick Start (macOS)

```bash
# 1. Run setup (installs/verifies dependencies)
chmod +x scripts/*.sh
./scripts/setup_mac.sh

# 2. Start everything
./scripts/run_all_local.sh
```

Or manually:

```bash
# Terminal 1: Backend
brew services start postgresql@16
cd backend
export JAVA_HOME=/opt/homebrew/Cellar/openjdk@21/21.0.10/libexec/openjdk.jdk/Contents/Home
/opt/homebrew/bin/mvn package -DskipTests
$JAVA_HOME/bin/java -jar target/ayrnow-backend-1.0.0-SNAPSHOT.jar

# Terminal 2: Frontend
cd frontend
flutter pub get
flutter run
```

## Required Environment Variables

Copy `backend/.env.example` and set values. Key vars:

| Variable | Purpose |
|----------|---------|
| `SPRING_DATASOURCE_URL` | PostgreSQL connection |
| `SPRING_DATASOURCE_USERNAME` | DB user |
| `SPRING_DATASOURCE_PASSWORD` | DB password |
| `JWT_SECRET` | Token signing key (min 32 chars) |
| `STRIPE_SECRET_KEY` | Stripe API key |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook verification |

See `backend/.env.example` for the full list.

## Project Structure

```
ayrnow-mvp/
├── backend/                    # Spring Boot API
│   ├── src/main/java/com/ayrnow/
│   │   ├── config/             # AppConfig
│   │   ├── controller/         # 14 REST controllers
│   │   ├── dto/                # Request/response objects
│   │   ├── entity/             # 15 JPA entities
│   │   ├── repository/         # 15 Spring Data repos
│   │   ├── security/           # JWT + Spring Security
│   │   └── service/            # 12 business services
│   └── src/main/resources/
│       ├── application.properties
│       └── db/migration/V1__Initial_schema.sql
├── frontend/                   # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart           # App entry + routing
│   │   ├── theme/              # Design tokens
│   │   ├── providers/          # State management
│   │   ├── services/           # API client
│   │   └── screens/            # 20 screen files
│   │       ├── auth/           # Login, Register, etc.
│   │       ├── landlord/       # Dashboard, Properties, etc.
│   │       ├── tenant/         # Dashboard, Lease, etc.
│   │       └── shared/         # Invites, Notifications, etc.
│   └── pubspec.yaml
├── docs/                       # Developer documentation
├── scripts/                    # Setup & run scripts
└── README.md
```

## Key Flows

1. **Landlord**: Register → Add Property → Add Units → Invite Tenant → Create Lease → Send for Signing → Collect Rent
2. **Tenant**: Accept Invite → Register → Sign Lease → Upload Documents → Pay Rent → Request Move-Out

## API Endpoints

See `docs/API_OVERVIEW.md` for the complete list of 48+ REST endpoints.

## Database Schema

See `docs/SCHEMA_OVERVIEW.md` or `backend/src/main/resources/db/migration/V1__Initial_schema.sql`.

## Documentation

| Document | Path |
|----------|------|
| Mac Setup Guide | `docs/SETUP_MAC.md` |
| iOS Simulator Guide | `docs/IOS_SIMULATOR.md` |
| API Overview | `docs/API_OVERVIEW.md` |
| Schema Overview | `docs/SCHEMA_OVERVIEW.md` |
| Auth Integration | `docs/AUTH_INTEGRATION.md` |
| OpenSign Integration | `docs/OPENSIGN_INTEGRATION.md` |
| Testing Guide | `docs/TESTING_GUIDE.md` |
| AWS Deployment Plan | `docs/AWS_DEPLOYMENT_PLAN.md` |
| Dependency Checklist | `docs/DEPENDENCY_CHECKLIST.md` |
| Route Map | `docs/ROUTE_MAP.md` |
| Module Map | `docs/MODULE_MAP.md` |

## No Docker Rule

AYRNOW does not use Docker anywhere. All services run natively on macOS. PostgreSQL via Homebrew, Spring Boot as a JAR, Flutter via the Flutter SDK.

## License

Proprietary — AYRNOW Inc.
