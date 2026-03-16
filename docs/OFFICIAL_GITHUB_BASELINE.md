# AYRNOW — Official GitHub Baseline

This document defines the secure operating baseline for the AYRNOW GitHub account and repository.

## Repository Policy

### Visibility
- **AYRNOW-MVP repo must be PRIVATE** — proprietary commercial code
- Public repos may be created for open-source tools or documentation only
- Never make a repo containing business logic, API keys, or customer data public

### Branch Model
- `main` is the production branch — always deployable
- Feature work happens in `feature/*` branches
- Hotfixes in `hotfix/*` branches
- No direct commits to `main` (enforced via branch protection when team > 1)

### Release Model
- Semantic versioning: `vMAJOR.MINOR.PATCH`
- Annotated tags for every release
- GitHub Releases created for significant versions
- No pre-release code deployed to production

## Secret Handling — Mandatory Rules

1. **Never commit secrets** — API keys, passwords, tokens, certificates
2. **Use environment variables** for all configuration
3. **Use `.env.example`** files to document required vars (with placeholders only)
4. **Enable GitHub secret scanning + push protection** on the repo
5. **If a secret is ever committed**: rotate it immediately, then clean history
6. **Stripe test keys** are safe in `.env` files locally but must never be in commits
7. **Production secrets** go in AWS Secrets Manager or Parameter Store only

## Contributor Workflow

### For Solo Developer
1. Work on `main` directly (current workflow)
2. Review `git diff --staged` before every commit
3. Tag meaningful releases
4. Push regularly to remote

### For Team (future)
1. Fork or branch from `main`
2. Open PR with description
3. At least 1 review before merge
4. CI checks must pass
5. Squash merge or rebase merge (no merge commits)
6. Delete feature branch after merge

### For External Contributors (if ever)
1. Fork the repo
2. Submit PRs from fork
3. All PRs reviewed by team
4. CLA or contribution agreement required
5. No direct repo access

## What Should Be Private vs Public

| Asset | Visibility |
|-------|-----------|
| AYRNOW-MVP source code | PRIVATE |
| Backend API code | PRIVATE |
| Flutter app code | PRIVATE |
| Database migrations | PRIVATE |
| Integration configs | PRIVATE |
| Documentation (internal) | PRIVATE (in repo) |
| Public marketing site | PUBLIC (separate repo) |
| Open-source utilities | PUBLIC (separate repo) |
| API documentation (for partners) | PUBLIC or authenticated |

## Release Publishing

1. Code is tested and verified locally
2. All secrets scanned — none in diff
3. Version bumped in config files
4. Annotated tag created
5. Pushed to remote
6. GitHub Release created with changelog
7. Build artifacts stored securely (not in repo)

## Incident Response

If a secret is committed:
1. **Do NOT panic-delete** — the secret is already in history
2. Rotate the secret immediately (new API key, new password, etc.)
3. Remove from code and commit the removal
4. Use `git filter-branch` or BFG Repo Cleaner to remove from history
5. Force push the cleaned history
6. Notify affected services
7. Document the incident

## Account Security Baseline

| Control | Required |
|---------|----------|
| 2FA enabled | YES |
| Recovery codes saved | YES |
| SSH key (Ed25519) | YES |
| Fine-grained PATs only | YES |
| Verified email | YES |
| Security log reviewed | Monthly |
| Unused tokens/keys removed | Quarterly |
