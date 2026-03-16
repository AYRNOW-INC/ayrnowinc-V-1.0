# Native Auth Architecture

AYRNOW owns authentication end-to-end using Spring Security + JJWT. No external auth provider is used.

---

## Architecture Overview

```
Flutter App
    |
    v
POST /api/auth/login  ──>  AuthController
                                |
                                v
                           AuthService
                           (validate, hash, issue tokens)
                                |
                                v
                           JwtProvider
                           (generate / validate JWT)
                                |
                                v
                           PostgreSQL
                           (users, roles tables)


Every subsequent request:

Flutter App
    |
    v
Authorization: Bearer <accessToken>
    |
    v
JwtAuthFilter  ──>  JwtProvider.validateToken()
    |                     |
    |                     v
    |               Extract userId + role
    |                     |
    v                     v
SecurityFilterChain  ──>  Controller (authorized)
```

## Core Components

### JwtProvider
- Location: `com.ayrnow.security.JwtProvider`
- Generates access tokens (30 min TTL) and refresh tokens (7 day TTL)
- Signs with HMAC-SHA256 using `JWT_SECRET` env var
- Parses and validates tokens, extracts userId and role claims
- Library: JJWT 0.12.6

### JwtAuthFilter
- Location: `com.ayrnow.security.JwtAuthFilter`
- Extends `OncePerRequestFilter`
- Reads `Authorization: Bearer <token>` header
- Calls `JwtProvider.validateToken()`, sets `SecurityContextHolder` authentication
- Skips filter for public paths (`/api/auth/**`)

### SecurityConfig
- Location: `com.ayrnow.security.SecurityConfig`
- Configures `SecurityFilterChain` bean
- Permits `/api/auth/**` without authentication
- Requires authentication for all other `/api/**` paths
- Disables CSRF (stateless API), enables CORS
- Registers `JwtAuthFilter` before `UsernamePasswordAuthenticationFilter`
- Provides `BCryptPasswordEncoder` bean

### AuthService
- Location: `com.ayrnow.service.AuthService`
- `register()`: validates input, hashes password with BCrypt, creates user + role + profile, processes invite if code provided, returns JWT pair
- `login()`: finds user by email, verifies password with BCrypt, returns JWT pair
- `refresh()`: validates refresh token, issues new access + refresh pair
- `me()`: returns current user from JWT-extracted userId

### AuthController
- Location: `com.ayrnow.controller.AuthController`
- `POST /api/auth/register` — registration
- `POST /api/auth/login` — login
- `POST /api/auth/refresh` — token refresh
- `GET /api/auth/me` — current user info

## Key Design Decisions

1. **Stateless JWT** — No server-side session store. Tokens carry all needed claims.
2. **BCrypt hashing** — Industry-standard password hashing via Spring Security.
3. **No Authgear** — AYRNOW controls the full auth lifecycle. No external auth dependency.
4. **Flyway for schema only** — Flyway manages database migrations. It is not an auth component.
5. **Role in JWT** — The user's role (LANDLORD/TENANT) is embedded in the JWT claims for fast authorization without DB lookups on every request.
6. **Refresh token rotation** — Each refresh call issues a brand-new token pair.

## Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `JWT_SECRET` | HMAC signing key (min 32 chars) | Required |
| `JWT_ACCESS_MINUTES` | Access token TTL | 30 |
| `JWT_REFRESH_DAYS` | Refresh token TTL | 7 |

## Future: Social Auth

Google Sign-In and Apple Sign-In are deferred. When implemented, they will use native OAuth flows (no Authgear), verifying ID tokens server-side and mapping to the same users/roles tables.
