# Backend Auth Flow

Detailed request-level flows for registration, login, token refresh, and authenticated access.

---

## Registration Flow

`POST /api/auth/register`

1. **AuthController** receives `RegisterRequest` (email, password, firstName, lastName, phone, role, inviteCode)
2. **AuthService.register()** validates:
   - Email not already in use (checks `UserRepository`)
   - Password meets minimum requirements
   - Role is LANDLORD or TENANT
3. Hash password with `BCryptPasswordEncoder`
4. Create `User` entity with email, passwordHash, firstName, lastName, phone, status=ACTIVE
5. Save user to `users` table
6. Create `Role` entity with userId and roleName
7. Save role to `roles` table
8. If role is LANDLORD: create `LandlordProfile` with userId, save to `landlord_profiles`
9. If role is TENANT: create `TenantProfile` with userId, save to `tenant_profiles`
10. If `inviteCode` is present: call `InvitationService.acceptInvite(inviteCode, userId)` — links tenant to unit/space
11. Generate access token (30 min) and refresh token (7 days) via `JwtProvider`
12. Return `AuthResponse` with accessToken, refreshToken, role, userId

## Login Flow

`POST /api/auth/login`

1. **AuthController** receives `LoginRequest` (email, password)
2. **AuthService.login()** finds user by email via `UserRepository`
3. If user not found: throw 401 Unauthorized
4. Verify password using `BCryptPasswordEncoder.matches(rawPassword, storedHash)`
5. If password mismatch: throw 401 Unauthorized
6. Load role from `RoleRepository.findByUserId()`
7. Generate access token and refresh token via `JwtProvider`
8. Return `AuthResponse` with accessToken, refreshToken, role, userId

## Token Refresh Flow

`POST /api/auth/refresh`

1. **AuthController** receives `RefreshRequest` (refreshToken)
2. **AuthService.refresh()** calls `JwtProvider.validateToken(refreshToken)`
3. If invalid or expired: throw 401 Unauthorized
4. Extract userId from token claims
5. Load user and role from database
6. Generate new access token and new refresh token
7. Return `AuthResponse` with fresh token pair

## Me Flow

`GET /api/auth/me`

1. Request passes through `JwtAuthFilter` (see below)
2. **AuthController.me()** extracts userId from `SecurityContextHolder`
3. Loads user + role from database
4. Returns user info (id, email, firstName, lastName, phone, role, status)

## Security Filter Chain Flow

Every request to a protected endpoint (`/api/**` except `/api/auth/**`):

1. Request arrives at `JwtAuthFilter.doFilterInternal()`
2. Extract `Authorization` header
3. If missing or not "Bearer ": pass through (Spring Security will reject as unauthenticated)
4. Extract token string after "Bearer "
5. Call `JwtProvider.validateToken(token)`
6. If valid: extract userId and role from claims
7. Create `UsernamePasswordAuthenticationToken` with userId as principal, role as authority
8. Set authentication in `SecurityContextHolder.getContext()`
9. Continue filter chain
10. Controller method executes with authenticated context

## Error Responses

| Scenario | HTTP Status | Body |
|---|---|---|
| Email already registered | 409 Conflict | `{"error": "Email already in use"}` |
| Invalid credentials | 401 Unauthorized | `{"error": "Invalid email or password"}` |
| Expired/invalid token | 401 Unauthorized | `{"error": "Token expired or invalid"}` |
| Missing auth header | 401 Unauthorized | Standard Spring Security response |
| Wrong role for endpoint | 403 Forbidden | `{"error": "Access denied"}` |

## Password Storage

- Algorithm: BCrypt (via `BCryptPasswordEncoder`)
- Strength: default (10 rounds)
- Raw passwords are never stored or logged
- Comparison uses constant-time `matches()` to prevent timing attacks
