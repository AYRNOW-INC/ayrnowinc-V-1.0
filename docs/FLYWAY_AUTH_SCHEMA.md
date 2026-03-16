# Flyway Auth Schema

Flyway manages all database schema migrations for AYRNOW. It is a schema migration tool only — it does not participate in authentication logic.

---

## Migration History

### V1 — Initial Schema
File: `V1__initial_schema.sql`

Creates the foundational tables including auth-related tables:
- `users` — credential and account storage
- `roles` — role assignments per user
- `landlord_profiles` — extended landlord info
- `tenant_profiles` — extended tenant info

Also creates: properties, unit_spaces, invitations, leases, lease_settings, lease_signatures, tenant_documents, payments, payment_transactions, move_out_requests, notifications, audit_logs.

### V2 — Stripe Support
File: `V2__stripe_support.sql`

Adds Stripe-related columns. No auth table changes.

### V3 — Native Auth Enhancements
File: `V3__native_auth_enhancements.sql`

Adds:
- `password_reset_tokens` table for future password reset flow
- `email_verified` column on `users` table (default false)
- Index on `users.email` for login lookup performance
- Index on `password_reset_tokens.token` for reset validation

---

## Auth-Related Table Definitions

### users

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | BIGSERIAL | PRIMARY KEY | Auto-increment |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Login identifier |
| password_hash | VARCHAR(255) | NOT NULL | BCrypt hash |
| first_name | VARCHAR(100) | NOT NULL | |
| last_name | VARCHAR(100) | NOT NULL | |
| phone | VARCHAR(30) | | Optional |
| email_verified | BOOLEAN | NOT NULL, DEFAULT false | Added in V3 |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'ACTIVE' | ACTIVE, SUSPENDED, PENDING |
| created_at | TIMESTAMP | NOT NULL, DEFAULT now() | |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT now() | |

Indexes:
- `idx_users_email` on `email` (added in V3)

### roles

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | BIGSERIAL | PRIMARY KEY | Auto-increment |
| user_id | BIGINT | NOT NULL, FK → users(id) | One role per user |
| role_name | VARCHAR(30) | NOT NULL | LANDLORD or TENANT |
| created_at | TIMESTAMP | NOT NULL, DEFAULT now() | |

Constraints:
- Foreign key on `user_id` referencing `users(id)`

### password_reset_tokens (V3)

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | BIGSERIAL | PRIMARY KEY | Auto-increment |
| user_id | BIGINT | NOT NULL, FK → users(id) | Token owner |
| token | VARCHAR(255) | NOT NULL, UNIQUE | Random reset token |
| expires_at | TIMESTAMP | NOT NULL | Expiration time |
| used | BOOLEAN | NOT NULL, DEFAULT false | One-time use |
| created_at | TIMESTAMP | NOT NULL, DEFAULT now() | |

Indexes:
- `idx_password_reset_token` on `token`

---

## Running Migrations

Flyway runs automatically on Spring Boot startup via `spring.flyway.enabled=true` (default).

Migration files location: `src/main/resources/db/migration/`

To check migration status:
```bash
JAVA_HOME=/opt/homebrew/Cellar/openjdk@21/21.0.10/libexec/openjdk.jdk/Contents/Home \
  ./mvnw flyway:info
```

## Rules

- Never edit an existing V-file after it has been applied. Create a new version instead.
- Auth schema changes go in new migration files (V4, V5, etc.).
- Flyway is a schema tool. It does not hash passwords, issue tokens, or enforce roles.
