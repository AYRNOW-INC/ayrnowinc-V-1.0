-- V3: Native authentication enhancements
-- Adds password reset tokens, email verification, and indexes for auth lookups.
-- AYRNOW uses native email/password auth with JJWT-issued tokens.
-- Flyway manages schema migrations only — it is NOT an auth provider.

-- ============================================================
-- PASSWORD RESET TOKENS
-- ============================================================

CREATE TABLE password_reset_tokens (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           VARCHAR(255) NOT NULL UNIQUE,
    expires_at      TIMESTAMP NOT NULL,
    used            BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_password_reset_token ON password_reset_tokens(token);
CREATE INDEX idx_password_reset_user ON password_reset_tokens(user_id);

-- ============================================================
-- EMAIL VERIFICATION
-- ============================================================

ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT FALSE;

-- ============================================================
-- AUTH INDEXES
-- ============================================================

-- Faster user lookup by external_id (used for future social OAuth provider links)
CREATE INDEX IF NOT EXISTS idx_users_external_id ON users(external_id);

-- Faster email lookup during login
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
