# AYRNOW — Git Workflow

## Branch Strategy

### Main Branches
| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Production-ready code | Protected — require PR, no force push |
| `develop` | Integration branch (optional for team) | Semi-protected |

### Feature Branches
- Format: `feature/<short-description>` (e.g., `feature/stripe-checkout`)
- Created from: `main` (or `develop` if using)
- Merged via: Pull Request
- Deleted after: merge

### Hotfix Branches
- Format: `hotfix/<issue-description>` (e.g., `hotfix/payment-webhook-fix`)
- Created from: `main`
- Merged to: `main` directly (with PR if team > 1)
- Tag immediately after merge

## Commit Message Convention

```
<type>: <short description>

<optional body>

Co-Authored-By: <name> <email>
```

### Types
| Type | When |
|------|------|
| `feat` | New feature or screen |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that doesn't fix a bug or add a feature |
| `test` | Adding or updating tests |
| `chore` | Build, config, or tooling changes |
| `security` | Security fix or hardening |

### Examples
```
feat: add lease signing screen with signature pad
fix: prevent duplicate webhook processing
docs: add Stripe integration guide
chore: update Flutter dependencies
security: remove dev JWT default from production config
```

## Release Process

1. Ensure all changes are committed and pushed
2. Update version in `pubspec.yaml` and/or `pom.xml`
3. Create annotated tag: `git tag -a v1.x.x -m "Release v1.x.x — description"`
4. Push tag: `git push origin v1.x.x`
5. Create GitHub Release from tag with changelog

### Version Format
- `v1.0.0` — Major.Minor.Patch
- Major: breaking changes or major milestones
- Minor: new features
- Patch: bug fixes, minor improvements

## Secret Handling

### DO
- Use environment variables for all secrets
- Use `.env.example` files to document required vars
- Use `${ENV_VAR:placeholder}` in Spring Boot properties
- Review `git diff --staged` before every commit

### DO NOT
- Commit `.env` files
- Hardcode API keys, passwords, or tokens in source code
- Include real credentials in commit messages or PR descriptions
- Use `git add .` or `git add -A` without reviewing what's staged

## Environment Separation

| Environment | Config Source | Secrets |
|-------------|-------------|---------|
| Local dev | `application.properties` defaults | Dev-only placeholders |
| Staging | Environment variables | AWS Parameter Store / Secrets Manager |
| Production | Environment variables | AWS Secrets Manager (rotated) |

## PR Checklist (for team workflow)
- [ ] Code compiles without errors
- [ ] No secrets in diff
- [ ] Commit messages follow convention
- [ ] New endpoints documented in API_OVERVIEW.md
- [ ] Schema changes have Flyway migration
- [ ] Flutter screens match wireframes
