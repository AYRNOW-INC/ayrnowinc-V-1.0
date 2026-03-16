# Environment Variables — Auth

Purpose: Documents all environment variables related to authentication and the backend runtime.

---

## Auth Variables

| Variable            | Required | Default | Description                              |
|---------------------|----------|---------|------------------------------------------|
| `JWT_SECRET`        | Yes      | —       | HMAC signing key for JWTs. Minimum 32 characters. Use a cryptographically random string. |
| `JWT_ACCESS_MINUTES`| No       | 30      | Access token lifetime in minutes.        |
| `JWT_REFRESH_DAYS`  | No       | 7       | Refresh token lifetime in days.          |

### JWT_SECRET

This is the only strictly required auth variable. If missing, the backend will fail to start. Generate one with:

```bash
openssl rand -base64 48
```

The secret must be at least 32 characters to satisfy JJWT 0.12.6 HMAC-SHA256 requirements.

## Database Variables

| Variable                    | Required | Default               | Description            |
|-----------------------------|----------|-----------------------|------------------------|
| `SPRING_DATASOURCE_URL`    | Yes      | `jdbc:postgresql://localhost:5432/ayrnow` | JDBC connection URL |
| `SPRING_DATASOURCE_USERNAME`| Yes     | `ayrnow`              | Database user          |
| `SPRING_DATASOURCE_PASSWORD`| Yes     | `ayrnow`              | Database password      |

## CORS Variables

| Variable               | Required | Default           | Description                     |
|------------------------|----------|-------------------|---------------------------------|
| `CORS_ALLOWED_ORIGINS` | No       | `http://localhost:*` | Comma-separated allowed origins |

## Payment Variables (Non-Auth, Listed for Completeness)

| Variable                | Required | Default | Description                |
|-------------------------|----------|---------|----------------------------|
| `STRIPE_SECRET_KEY`     | Yes*     | —       | Stripe API secret key      |
| `STRIPE_WEBHOOK_SECRET` | Yes*     | —       | Stripe webhook signing key |

*Required only if payment flows are active.

## What Is NOT Needed

- No `AUTHGEAR_*` variables. AYRNOW uses native auth, not Authgear.
- No `OPENSIGN_*` variables for auth. OpenSign is only used for lease signing.
- No Docker-related environment variables.
- No external OAuth provider secrets (Google/Apple social login is deferred).

## Local Development Setup

Copy `.env.example` to `.env` in the backend root and fill in values:

```bash
cp .env.example .env
```

The `.env.example` file contains all variables with safe local defaults. For local dev, the defaults for database and JWT timing are sufficient. You must still set `JWT_SECRET`.

## Production Notes

- Use AWS Secrets Manager or SSM Parameter Store for `JWT_SECRET` and database credentials.
- Rotate `JWT_SECRET` periodically. Rotation invalidates all existing tokens — users must re-login.
- Never commit real secrets to the repository.
