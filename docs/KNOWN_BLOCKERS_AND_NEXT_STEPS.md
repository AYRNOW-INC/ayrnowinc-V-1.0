# Known Blockers and Next Steps — Auth

Purpose: Tracks what is working, what is deferred, and what needs to be built next for AYRNOW auth.

---

## What Is Working

- **Registration**: Landlord and tenant registration with BCrypt password hashing.
- **Login**: Email/password login returning JWT access + refresh token pair.
- **Token refresh**: Refresh endpoint issues new token pairs.
- **Identity check**: `/api/auth/me` returns authenticated user with roles.
- **Role assignment**: LANDLORD and TENANT roles stored in `roles` table at registration.
- **Role enforcement**: Backend checks role on protected endpoints (properties, leases, invitations, etc.).
- **Flyway migrations**: V1 (core schema) and V3 (auth hardening) applied cleanly.
- **Flutter integration**: Login, register, token storage, and auth gate all functional.
- **Stateless JWT**: No server-side session storage. Tokens are self-contained.

## What Is Deferred

### Social Auth (Google/Apple Sign-In)

- **Status**: Not implemented. Deferred to a future phase.
- **Approach**: Will use native OAuth (Spring Security OAuth2 client + Flutter oauth packages), NOT an external provider like Authgear.
- **Schema ready**: `external_id` column on `users` and `idx_users_external_id` index exist for future OAuth provider IDs.
- **No timeline set.**

### Email Verification

- **Status**: Schema ready, send logic not implemented.
- **Schema**: `email_verified` boolean column added in V3 migration, defaults to `FALSE`.
- **Next step**: Implement email sending (via AWS SES or similar), verification endpoint, and enforce verification on sensitive actions.
- **Current behavior**: Users can operate without verifying email.

### Password Reset

- **Status**: Schema ready, endpoint not implemented.
- **Schema**: `password_reset_tokens` table added in V3 migration with token, expiry, and used flag.
- **Next step**: Implement `POST /api/auth/forgot-password` (generates token, sends email) and `POST /api/auth/reset-password` (validates token, updates password).
- **Depends on**: Email sending infrastructure.

## Known Blockers (Non-Auth)

These affect the project but are not auth-specific:

1. **Git push protection**: Secret-in-history issue blocks pushing to GitHub.
2. **AWS deployment**: Deploy runbook not finalized.
3. **App store submissions**: iOS/Android store listings and signing not complete.

## Recommended Next Steps (Auth)

1. Implement password reset endpoints (schema already exists).
2. Implement email verification flow (schema already exists).
3. Add rate limiting to `/api/auth/login` and `/api/auth/register`.
4. Add token blacklist or short-lived refresh tokens for logout.
5. Implement native Google OAuth (Spring Security OAuth2 + Flutter `google_sign_in`).
6. Implement native Apple Sign-In (Spring Security + Flutter `sign_in_with_apple`).
7. Add account lockout after repeated failed login attempts.
