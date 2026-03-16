# Landlord Auth Flow

Purpose: Documents the landlord-specific authentication and authorization journey in AYRNOW.

---

## Overview

AYRNOW uses native Spring Boot authentication with JWT tokens. There is no external auth provider. Landlords register with role `LANDLORD`, receive a JWT pair, and access landlord-specific resources enforced by backend role checks.

## Registration

1. Landlord calls `POST /api/auth/register` with:
   ```json
   {
     "email": "landlord@example.com",
     "password": "securePassword123",
     "firstName": "Jane",
     "lastName": "Doe",
     "role": "LANDLORD"
   }
   ```
2. Backend creates a `users` row, assigns the `LANDLORD` role in the `roles` table, and creates a `landlord_profiles` row.
3. Response includes `accessToken` (30 min) and `refreshToken` (7 days).

## Login

1. Landlord calls `POST /api/auth/login` with email and password.
2. Backend validates credentials via BCrypt, issues a new JWT pair.
3. Flutter stores tokens securely and attaches the access token as `Authorization: Bearer <token>` on all subsequent requests.

## Session Lifecycle

- Access token expires after 30 minutes (configurable via `JWT_ACCESS_MINUTES`).
- Refresh token expires after 7 days (configurable via `JWT_REFRESH_DAYS`).
- Flutter calls `POST /api/auth/refresh` with the refresh token before expiry to get a new pair.
- If the refresh token is expired, the user must log in again.

## Identity Check

`GET /api/auth/me` returns the authenticated user's profile including roles. Flutter uses this on app launch to determine whether to show the landlord or tenant dashboard.

## Role-Based Access

The backend enforces `LANDLORD` role on all landlord-specific endpoints:

| Resource             | Required Role | Example Endpoint               |
|----------------------|---------------|--------------------------------|
| Properties           | LANDLORD      | `POST /api/properties`         |
| Lease Settings       | LANDLORD      | `PUT /api/lease-settings/{id}` |
| Tenant Invitations   | LANDLORD      | `POST /api/invitations`        |
| Lease Creation       | LANDLORD      | `POST /api/leases`             |
| Move-Out Review      | LANDLORD      | `PUT /api/move-out/{id}`       |
| Document Review      | LANDLORD      | `GET /api/documents/{id}`      |

Unauthorized requests receive `403 Forbidden`.

## Flutter Integration

- `AuthService` handles register, login, refresh, and token storage.
- `AuthGate` widget checks token validity on app launch.
- On successful landlord auth, the app navigates to `LandlordShell` which hosts the landlord dashboard, property list, and other landlord screens.

## Key Rules

- Landlord role is assigned at registration time and stored in PostgreSQL.
- There is no external identity provider. AYRNOW owns the full auth lifecycle.
- Social login (Google/Apple) is deferred to a future native OAuth phase.
- Password is hashed with BCrypt before storage. Raw passwords are never persisted.
