# AYRNOW — GitHub Account Security Checklist

This checklist is for the GitHub account used as the official AYRNOW company account.

## Authentication
- [ ] **Enable 2FA (Two-Factor Authentication)**
  - Settings → Password and authentication → Two-factor authentication
  - Use authenticator app (not SMS — SMS is less secure)
  - Recommended: 1Password, Authy, or Google Authenticator

- [ ] **Save recovery codes**
  - Store in a secure location (password manager, printed in safe)
  - These are the only way to recover your account if you lose 2FA device

- [ ] **Add a security key or passkey** (recommended)
  - Settings → Password and authentication → Security keys
  - Hardware key (YubiKey) or platform passkey provides strongest protection

## SSH Keys
- [ ] **Review SSH keys**: Settings → SSH and GPG keys
  - Remove any unrecognized or old keys
  - Each key should have a descriptive title (e.g., "MacBook Pro 2024")
  - Use Ed25519 keys: `ssh-keygen -t ed25519 -C "your@email.com"`

## Personal Access Tokens
- [ ] **Review tokens**: Settings → Developer settings → Personal access tokens
  - Delete any unused or expired tokens
  - **Prefer fine-grained tokens** over classic tokens
  - Fine-grained tokens can be scoped to specific repos and permissions
  - Set expiration dates (90 days recommended)
  - Never share tokens in code, chat, or email

## Email & Identity
- [ ] **Verify primary email**: Settings → Emails
  - Use a company email if available (e.g., admin@ayrnow.com)
  - Mark it as verified

- [ ] **Set commit email**: Settings → Emails → "Keep my email addresses private"
  - Use GitHub's noreply email for commits to avoid exposing personal email
  - Or use a verified company email

- [ ] **Check git config locally**:
  ```bash
  git config user.name   # Should match GitHub display name
  git config user.email  # Should match verified GitHub email
  ```

## Security Log
- [ ] **Review security log**: Settings → Security log
  - Check for any unauthorized access or suspicious activity
  - Review recent authentication events

## Profile (for official company account)
- [ ] **Profile photo**: Use AYRNOW logo or professional headshot
- [ ] **Bio**: "Official AYRNOW development account" or similar
- [ ] **Company**: AYRNOW Inc.
- [ ] **Location**: United States
- [ ] **Website**: ayrnow.com (when available)
- [ ] **Make email private** if using personal email

## Sessions
- [ ] **Review active sessions**: Settings → Sessions
  - Revoke any sessions from unrecognized devices or locations
