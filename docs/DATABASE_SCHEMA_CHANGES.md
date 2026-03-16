# Database Schema Changes — Auth

Purpose: Documents all auth-related database tables and migrations managed by Flyway.

---

## Migration History

| Version | Description                                      |
|---------|--------------------------------------------------|
| V1      | Initial schema: users, roles, landlord/tenant profiles, properties, units, leases, payments, etc. |
| V3      | Auth hardening: password_reset_tokens table, email_verified column, performance indexes |

## V1 Tables (Auth-Related)

### users

| Column       | Type                     | Notes                          |
|--------------|--------------------------|--------------------------------|
| id           | BIGSERIAL PRIMARY KEY    |                                |
| external_id  | VARCHAR(255) UNIQUE      | For future OAuth provider IDs  |
| email        | VARCHAR(255) UNIQUE, NOT NULL |                           |
| password     | VARCHAR(255)             | BCrypt hash                    |
| first_name   | VARCHAR(100)             |                                |
| last_name    | VARCHAR(100)             |                                |
| phone        | VARCHAR(20)              |                                |
| status       | VARCHAR(20) DEFAULT 'ACTIVE' |                            |
| created_at   | TIMESTAMP                |                                |
| updated_at   | TIMESTAMP                |                                |

### roles

| Column  | Type                     | Notes                    |
|---------|--------------------------|--------------------------|
| id      | BIGSERIAL PRIMARY KEY    |                          |
| user_id | BIGINT FK -> users(id)   |                          |
| role    | VARCHAR(20) NOT NULL     | LANDLORD or TENANT       |

### landlord_profiles

| Column       | Type                     | Notes                    |
|--------------|--------------------------|--------------------------|
| id           | BIGSERIAL PRIMARY KEY    |                          |
| user_id      | BIGINT FK -> users(id)   | UNIQUE                   |
| company_name | VARCHAR(255)             |                          |
| bio          | TEXT                     |                          |
| created_at   | TIMESTAMP                |                          |
| updated_at   | TIMESTAMP                |                          |

### tenant_profiles

| Column     | Type                     | Notes                    |
|------------|--------------------------|--------------------------|
| id         | BIGSERIAL PRIMARY KEY    |                          |
| user_id    | BIGINT FK -> users(id)   | UNIQUE                   |
| created_at | TIMESTAMP                |                          |
| updated_at | TIMESTAMP                |                          |

## V3 Additions

### password_reset_tokens (new table)

| Column     | Type                     | Notes                    |
|------------|--------------------------|--------------------------|
| id         | BIGSERIAL PRIMARY KEY    |                          |
| user_id    | BIGINT FK -> users(id)   |                          |
| token      | VARCHAR(255) UNIQUE, NOT NULL | Secure random token |
| expires_at | TIMESTAMP NOT NULL       |                          |
| used       | BOOLEAN DEFAULT FALSE    |                          |
| created_at | TIMESTAMP                |                          |

### New columns

| Table | Column         | Type    | Default | Notes                    |
|-------|----------------|---------|---------|--------------------------|
| users | email_verified | BOOLEAN | FALSE   | For future email verification flow |

### New indexes

| Index Name             | Table | Column(s)   | Purpose                  |
|------------------------|-------|-------------|--------------------------|
| idx_users_external_id  | users | external_id | Fast OAuth lookups        |
| idx_users_email        | users | email       | Fast login lookups        |

## Rules

- **Flyway manages ALL schema changes.** No manual SQL against the database.
- Migration files live in `src/main/resources/db/migration/`.
- File naming: `V{n}__description.sql` (double underscore).
- Never edit a migration that has already been applied. Create a new version instead.
- Run `mvn flyway:info` to check migration status.
