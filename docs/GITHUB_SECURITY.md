# AYRNOW — GitHub Security Audit Report

Date: 2026-03-15

## Audit Results

### Secret Scan — CLEAN
| Check | Result |
|-------|--------|
| Real Stripe keys (sk_test_/sk_live_/pk_test_/pk_live_) in history | NONE FOUND |
| Real webhook secrets (whsec_) in history | NONE FOUND |
| Private keys (PEM/P12/JKS) in history | NONE FOUND |
| AWS credentials (AKIA...) | NONE FOUND |
| GitHub tokens (ghp_) | NONE FOUND |
| Hardcoded passwords | NONE (all use env var fallbacks) |
| .env files tracked | NONE (.env in .gitignore) |
| Keystores tracked | NONE |
| Service account files | NONE |

### Application Properties — SAFE (with caveats)
`application.properties` uses `${ENV_VAR:default}` pattern for all secrets. Defaults are placeholders:
- `SPRING_DATASOURCE_PASSWORD` → default `ayrnow` (dev-only, local PostgreSQL)
- `JWT_SECRET` → default `dev-secret-key-change-in-production-min-32-chars!!` (dev-only)
- `STRIPE_SECRET_KEY` → default `sk_test_placeholder` (not a real key)
- `STRIPE_WEBHOOK_SECRET` → default `whsec_placeholder` (not a real key)

**Risk**: The dev defaults are safe for open-source but should be removed or replaced with empty strings for production builds. The `dev-secret` JWT default could theoretically allow local JWT forgery — but only against a dev instance.

**Recommendation**: For production, require all env vars (remove defaults) or set defaults to empty string so app fails to start without proper config.

### .gitignore — ADEQUATE
Current `.gitignore` covers:
- `.env` files (all patterns)
- `backend/target/` (build output)
- `frontend/build/` + `.dart_tool/`
- IDE files (`.idea/`, `.vscode/`)
- OS files (`.DS_Store`)
- Uploads directory
- Logs
- Android `local.properties`
- iOS Pods and user data

**Missing entries added** (see git hygiene fixes below):
- `*.keystore`, `*.jks`, `*.p12` (signing keystores)
- `key.properties` (Android signing config)
- `google-services.json`, `GoogleService-Info.plist` (Firebase configs)
- `*.pem`, `*.key` (TLS certificates)
- `service-account*.json` (cloud credentials)

### Commit History — CLEAN
- 3 commits, all well-structured
- No secret leaks detected across all commits
- No force-push history issues
- Tags (v1.0.0, v1.0.1) are meaningful and clean

### Untracked Files — REVIEWED
Several Flutter platform directories are untracked (android/, ios/, web/, etc.). These contain boilerplate config but also `local.properties` (already gitignored). Safe to add platform dirs in a future commit if desired.

## Security Best Practices for This Repo

1. **Never commit real API keys, secrets, or credentials**
2. **Always use environment variables** — `${ENV_VAR:fallback}` pattern in Spring Boot
3. **Use `.env.example` files** to document required vars with placeholder values
4. **Review diffs before every commit** — `git diff --staged` before `git commit`
5. **Enable GitHub secret scanning** on the repo (see GITHUB_SETTINGS_CHECKLIST.md)
6. **Enable push protection** to prevent accidental secret pushes
7. **Rotate credentials immediately** if any are ever committed
8. **Use fine-grained personal access tokens** instead of classic tokens
9. **Use SSH keys** for Git authentication (currently configured)
