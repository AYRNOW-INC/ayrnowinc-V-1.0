# AYRNOW — GitHub Repository Settings Checklist

Apply these settings manually in the GitHub web UI at:
`https://github.com/ayrnowinc-jpg/AYRNOW-MVP/settings`

## 1. Repository Visibility
- [ ] **Set to Private** — this is a proprietary commercial product
  - Settings → General → Danger Zone → Change visibility → Private
  - This prevents public access to source code, commit history, and issues

## 2. Branch Protection (main)
Go to: Settings → Branches → Add branch protection rule

- **Branch name pattern**: `main`
- [ ] **Require a pull request before merging** (enable when team > 1 person)
  - [ ] Require approvals: 1
  - [ ] Dismiss stale PR reviews when new commits are pushed
- [ ] **Require status checks to pass before merging** (enable when CI is set up)
- [ ] **Require conversation resolution before merging**
- [x] **Do not allow force pushes** — CRITICAL
- [x] **Do not allow deletions** — prevents accidental main branch deletion
- [ ] **Require signed commits** (optional, adds verification)
- [ ] **Restrict who can push** — limit to repo admin only

## 3. Security Features
Go to: Settings → Code security and analysis

- [x] **Dependency graph** — Enable (shows dependencies)
- [x] **Dependabot alerts** — Enable (vulnerability notifications)
- [ ] **Dependabot security updates** — Enable (auto PRs for vulnerable deps)
- [x] **Secret scanning** — Enable (detects accidentally committed secrets)
- [x] **Push protection** — Enable (blocks pushes containing secrets)
  - This would have caught any real secret pushes

## 4. Actions Permissions
Go to: Settings → Actions → General

- [ ] **Allow all actions** or **Allow actions from this repository only**
- [ ] **Require approval for first-time contributors** (if using Actions)
- [ ] Set **default workflow permissions** to Read (least privilege)

## 5. Collaborator Access
Go to: Settings → Collaborators and teams

- [ ] Review all collaborators
- [ ] Use **least privilege** — give Write access only to active developers
- [ ] Use **Admin** only for repo owner
- [ ] Remove inactive collaborators
- [ ] Consider using a GitHub Organization for team management

## 6. Deploy Keys / SSH
Go to: Settings → Deploy keys

- [ ] Review all deploy keys
- [ ] Remove any unused keys
- [ ] Use **read-only** deploy keys for CI/CD (unless write is needed)
- [ ] Do not use personal SSH keys as deploy keys

## 7. Webhooks
Go to: Settings → Webhooks

- [ ] Review all webhooks
- [ ] Ensure webhook secrets are set and rotated periodically
- [ ] Only configure webhooks to trusted HTTPS endpoints

## 8. CODEOWNERS (optional, for team)
Create `.github/CODEOWNERS` to auto-assign PR reviewers:
```
# Default owner for everything
* @ayrnowinc-jpg

# Backend changes require backend review
backend/ @ayrnowinc-jpg

# Frontend changes require frontend review
frontend/ @ayrnowinc-jpg
```

## 9. Issue/PR Templates (optional)
- [ ] Create `.github/ISSUE_TEMPLATE/` for bug reports and feature requests
- [ ] Create `.github/PULL_REQUEST_TEMPLATE.md` for PR description format

## Priority Order
1. **Set repo to Private** (most important for commercial code)
2. **Enable secret scanning + push protection**
3. **Protect main branch** (no force push, no deletion)
4. **Enable Dependabot alerts**
5. **Review collaborator access**
