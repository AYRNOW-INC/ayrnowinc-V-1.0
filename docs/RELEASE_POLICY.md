# AYRNOW — Release Policy

## Versioning
Semantic Versioning: `vMAJOR.MINOR.PATCH`

| Component | When to bump |
|-----------|-------------|
| MAJOR | Breaking API changes, major architecture change, or production milestone |
| MINOR | New features, new screens, new endpoints |
| PATCH | Bug fixes, dependency updates, documentation, minor improvements |

## Current Releases
| Tag | Commit | Description |
|-----|--------|-------------|
| v1.0.0 | f44f577 | MVP with all screens, docs, scripts |
| v1.0.1 | f091f5e | Stripe integration with idempotent webhooks |

## Release Checklist
Before creating a release tag:

1. **Code quality**
   - [ ] `flutter analyze` reports 0 errors
   - [ ] Backend compiles: `mvn package -DskipTests`
   - [ ] Backend starts and health endpoint returns UP
   - [ ] App runs on iOS simulator

2. **Security**
   - [ ] `git diff --staged` reviewed for secrets
   - [ ] No `.env` files tracked
   - [ ] No hardcoded keys or passwords
   - [ ] .gitignore is up to date

3. **Documentation**
   - [ ] CHANGED_FILES.md updated
   - [ ] API_OVERVIEW.md updated if endpoints changed
   - [ ] SCHEMA_OVERVIEW.md updated if migrations added

4. **Tagging**
   ```bash
   git tag -a v1.x.x -m "AYRNOW v1.x.x — description"
   git push origin v1.x.x
   ```

5. **GitHub Release** (optional but recommended)
   - Create release from tag in GitHub UI
   - Include changelog/summary

## Hotfix Process
1. Create branch: `hotfix/description`
2. Fix the issue
3. Test locally
4. Merge to main (PR if team)
5. Tag as patch release (v1.x.PATCH+1)
6. Push

## Pre-Release Tags
For testing before official release:
- `v1.2.0-rc.1` — Release candidate
- `v1.2.0-beta.1` — Beta
- Do not use pre-release tags for production deployment
