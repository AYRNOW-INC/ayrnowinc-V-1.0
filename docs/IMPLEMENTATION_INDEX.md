# Implementation Index — AYRNOW Auth

Purpose: Master index for all auth-related documentation. Start here to understand the AYRNOW authentication system.

---

## Auth Documentation

| File | Description |
|------|-------------|
| [LANDLORD_AUTH_FLOW.md](./LANDLORD_AUTH_FLOW.md) | Landlord registration, login, token lifecycle, and role-based access rules |
| [DATABASE_SCHEMA_CHANGES.md](./DATABASE_SCHEMA_CHANGES.md) | Auth-related tables (users, roles, profiles, password_reset_tokens) and Flyway migrations |
| [ENVIRONMENT_VARIABLES.md](./ENVIRONMENT_VARIABLES.md) | JWT_SECRET, token lifetimes, database config, and what is NOT needed |
| [TESTING_AND_VERIFICATION.md](./TESTING_AND_VERIFICATION.md) | curl-based manual test flow, expected HTTP codes, Flutter and backend verification commands |
| [KNOWN_BLOCKERS_AND_NEXT_STEPS.md](./KNOWN_BLOCKERS_AND_NEXT_STEPS.md) | What works, what is deferred (social auth, email verify, password reset), and recommended next steps |

## Related Non-Auth Documentation

| File | Description |
|------|-------------|
| [API_OVERVIEW.md](./API_OVERVIEW.md) | Full API endpoint reference across all modules |
| [SCHEMA_OVERVIEW.md](./SCHEMA_OVERVIEW.md) | Complete database schema including non-auth tables |
| [SETUP_MAC.md](./SETUP_MAC.md) | Local development setup for macOS |
| [MODULE_MAP.md](./MODULE_MAP.md) | Backend module structure and package layout |
| [ROUTE_MAP.md](./ROUTE_MAP.md) | Flutter route definitions and screen navigation |
| [TESTING_GUIDE.md](./TESTING_GUIDE.md) | General testing strategy and test file locations |
| [STRIPE_INTEGRATION.md](./STRIPE_INTEGRATION.md) | Payment integration details |
| [OPENSIGN_INTEGRATION.md](./OPENSIGN_INTEGRATION.md) | Lease signing integration details |
| [AWS_DEPLOYMENT_PLAN.md](./AWS_DEPLOYMENT_PLAN.md) | Production deployment strategy |

## Architecture Summary

```
Flutter App
  -> AuthService (register/login/refresh/me)
  -> Token storage (secure local)
  -> AuthGate widget (checks token on launch)
  -> Routes to LandlordShell or TenantShell based on role

Spring Boot Backend
  -> AuthController (4 endpoints)
  -> JwtService (JJWT 0.12.6, HMAC-SHA256)
  -> BCrypt password hashing
  -> Role-based method security
  -> PostgreSQL (users, roles, profiles, tokens)
  -> Flyway (versioned migrations)
```

## Key Decisions

- **Native auth, not Authgear.** AYRNOW owns the full auth lifecycle.
- **Stateless JWT.** No server-side session table.
- **Social auth deferred.** Will be native OAuth when implemented, not an external provider.
- **No Docker.** Backend runs as a standard Spring Boot JAR.
