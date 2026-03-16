# Testing and Verification — Auth

Purpose: Practical steps to verify the AYRNOW auth system works end-to-end.

---

## Prerequisites

- PostgreSQL 16 running with `ayrnow` database created
- Java 21, Maven installed
- `JWT_SECRET` set (min 32 chars)

## 1. Build and Start Backend

```bash
export JAVA_HOME=/opt/homebrew/Cellar/openjdk@21/21.0.10/libexec/openjdk.jdk/Contents/Home
cd /Users/imranshishir/Documents/claude/AYRNOW/ayrnow-mvp/backend
mvn clean compile -q
mvn spring-boot:run
```

Backend starts on `http://localhost:8080`. Flyway runs migrations automatically on startup.

## 2. Verify Flyway Migrations

```bash
mvn flyway:info
```

All migrations should show status `Success`. Check for V1 and V3 specifically.

## 3. Manual Auth Test Flow

### Register a landlord

```bash
curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234!","firstName":"Jane","lastName":"Doe","role":"LANDLORD"}' | jq .
```

Expected: `200 OK` with `accessToken` and `refreshToken`.

### Login

```bash
curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234!"}' | jq .
```

Expected: `200 OK` with new token pair.

### Check identity

```bash
curl -s http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq .
```

Expected: `200 OK` with user profile including `roles: ["LANDLORD"]`.

### Refresh tokens

```bash
curl -s -X POST http://localhost:8080/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}' | jq .
```

Expected: `200 OK` with new token pair.

### Test protected endpoint without token

```bash
curl -s http://localhost:8080/api/properties
```

Expected: `401 Unauthorized`.

### Test protected endpoint with wrong role

Register as TENANT, then try to create a property:

```bash
curl -s -X POST http://localhost:8080/api/properties \
  -H "Authorization: Bearer <TENANT_ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test"}'
```

Expected: `403 Forbidden`.

## 4. Expected HTTP Codes

| Scenario                  | Code |
|---------------------------|------|
| Successful register/login | 200  |
| Invalid credentials       | 401  |
| Missing token             | 401  |
| Expired token             | 401  |
| Wrong role                | 403  |
| Duplicate email register  | 409  |
| Validation error          | 400  |

## 5. Flutter Verification

```bash
cd /Users/imranshishir/Documents/claude/AYRNOW/ayrnow-mvp/frontend
flutter analyze
```

Expected: zero errors. Warnings are acceptable but should be reviewed.

## 6. Existing Test Files

- `test/core_routes_regression_test.dart` — verifies login/register/property routes exist
- `test/auth_phase1_test.dart` — auth flow unit tests
- `test/widget_test.dart` — basic widget tests

Run with: `flutter test`
