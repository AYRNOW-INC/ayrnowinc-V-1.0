-- AYRNOW MVP Initial Schema
-- V1: Core tables for auth, properties, leases, payments, documents, move-out

-- ============================================================
-- USERS & ROLES
-- ============================================================

CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    external_id     VARCHAR(255) UNIQUE,          -- Authgear user ID
    email           VARCHAR(255) NOT NULL UNIQUE,
    phone           VARCHAR(50),
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE roles (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            VARCHAR(20) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, role)
);

CREATE INDEX idx_roles_user_id ON roles(user_id);

-- ============================================================
-- LANDLORD & TENANT PROFILES
-- ============================================================

CREATE TABLE landlord_profiles (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    company_name    VARCHAR(255),
    business_address VARCHAR(500),
    tax_id          VARCHAR(100),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE tenant_profiles (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth   DATE,
    ssn_last_four   VARCHAR(4),
    employer        VARCHAR(255),
    annual_income   DECIMAL(12,2),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- PROPERTIES & UNIT SPACES
-- ============================================================

CREATE TABLE properties (
    id              BIGSERIAL PRIMARY KEY,
    landlord_id     BIGINT NOT NULL REFERENCES users(id),
    name            VARCHAR(255) NOT NULL,
    property_type   VARCHAR(20) NOT NULL,           -- RESIDENTIAL, COMMERCIAL, OTHER
    address         VARCHAR(500) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(50) NOT NULL,
    postal_code     VARCHAR(20) NOT NULL,
    country         VARCHAR(50) NOT NULL DEFAULT 'US',
    description     TEXT,
    image_url       VARCHAR(500),
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_properties_landlord ON properties(landlord_id);

CREATE TABLE unit_spaces (
    id              BIGSERIAL PRIMARY KEY,
    property_id     BIGINT NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    unit_type       VARCHAR(30) NOT NULL,           -- APARTMENT, FLAT, ROOM, UNIT, STORE, OFFICE, SHOP, WAREHOUSE, LAND_BLOCK, LOT, PARCEL, OTHER
    floor           VARCHAR(20),
    bedrooms        INTEGER,
    bathrooms       DECIMAL(3,1),
    square_feet     DECIMAL(10,2),
    monthly_rent    DECIMAL(10,2),
    status          VARCHAR(20) NOT NULL DEFAULT 'VACANT',  -- VACANT, OCCUPIED, MAINTENANCE
    description     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_unit_spaces_property ON unit_spaces(property_id);

-- ============================================================
-- INVITATIONS
-- ============================================================

CREATE TABLE invitations (
    id              BIGSERIAL PRIMARY KEY,
    landlord_id     BIGINT NOT NULL REFERENCES users(id),
    unit_space_id   BIGINT NOT NULL REFERENCES unit_spaces(id),
    tenant_email    VARCHAR(255),
    tenant_phone    VARCHAR(50),
    invite_code     VARCHAR(20) NOT NULL UNIQUE,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    expires_at      TIMESTAMP NOT NULL,
    accepted_at     TIMESTAMP,
    tenant_id       BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invitations_landlord ON invitations(landlord_id);
CREATE INDEX idx_invitations_code ON invitations(invite_code);
CREATE INDEX idx_invitations_unit ON invitations(unit_space_id);

-- ============================================================
-- LEASE SETTINGS (property-level defaults)
-- ============================================================

CREATE TABLE lease_settings (
    id                  BIGSERIAL PRIMARY KEY,
    property_id         BIGINT NOT NULL UNIQUE REFERENCES properties(id) ON DELETE CASCADE,
    default_lease_term_months INTEGER DEFAULT 12,
    default_monthly_rent    DECIMAL(10,2),
    default_security_deposit DECIMAL(10,2),
    payment_due_day     INTEGER DEFAULT 1,
    grace_period_days   INTEGER DEFAULT 5,
    late_fee_amount     DECIMAL(10,2) DEFAULT 0,
    late_fee_type       VARCHAR(20) DEFAULT 'FLAT',  -- FLAT, PERCENTAGE
    special_terms       TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- LEASES
-- ============================================================

CREATE TABLE leases (
    id                  BIGSERIAL PRIMARY KEY,
    property_id         BIGINT NOT NULL REFERENCES properties(id),
    unit_space_id       BIGINT NOT NULL REFERENCES unit_spaces(id),
    landlord_id         BIGINT NOT NULL REFERENCES users(id),
    tenant_id           BIGINT NOT NULL REFERENCES users(id),
    lease_term_months   INTEGER NOT NULL,
    monthly_rent        DECIMAL(10,2) NOT NULL,
    security_deposit    DECIMAL(10,2),
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    payment_due_day     INTEGER DEFAULT 1,
    grace_period_days   INTEGER DEFAULT 5,
    late_fee_amount     DECIMAL(10,2) DEFAULT 0,
    late_fee_type       VARCHAR(20) DEFAULT 'FLAT',
    special_terms       TEXT,
    status              VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    document_url        VARCHAR(500),
    opensign_doc_id     VARCHAR(255),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leases_property ON leases(property_id);
CREATE INDEX idx_leases_landlord ON leases(landlord_id);
CREATE INDEX idx_leases_tenant ON leases(tenant_id);
CREATE INDEX idx_leases_unit ON leases(unit_space_id);

-- ============================================================
-- LEASE SIGNATURES
-- ============================================================

CREATE TABLE lease_signatures (
    id              BIGSERIAL PRIMARY KEY,
    lease_id        BIGINT NOT NULL REFERENCES leases(id) ON DELETE CASCADE,
    signer_id       BIGINT NOT NULL REFERENCES users(id),
    signer_role     VARCHAR(20) NOT NULL,           -- LANDLORD, TENANT
    signed          BOOLEAN NOT NULL DEFAULT FALSE,
    signed_at       TIMESTAMP,
    signature_data  TEXT,
    ip_address      VARCHAR(50),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lease_signatures_lease ON lease_signatures(lease_id);

-- ============================================================
-- TENANT DOCUMENTS
-- ============================================================

CREATE TABLE tenant_documents (
    id              BIGSERIAL PRIMARY KEY,
    tenant_id       BIGINT NOT NULL REFERENCES users(id),
    lease_id        BIGINT REFERENCES leases(id),
    document_type   VARCHAR(30) NOT NULL,           -- ID, PROOF_OF_INCOME, BACKGROUND_CHECK
    file_name       VARCHAR(255) NOT NULL,
    file_path       VARCHAR(500) NOT NULL,
    file_type       VARCHAR(10) NOT NULL,           -- PDF, JPG, JPEG, PNG
    file_size       BIGINT,
    status          VARCHAR(20) NOT NULL DEFAULT 'UPLOADED',
    review_comment  TEXT,
    reviewed_by     BIGINT REFERENCES users(id),
    reviewed_at     TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tenant_documents_tenant ON tenant_documents(tenant_id);
CREATE INDEX idx_tenant_documents_lease ON tenant_documents(lease_id);

-- ============================================================
-- PAYMENTS
-- ============================================================

CREATE TABLE payments (
    id              BIGSERIAL PRIMARY KEY,
    tenant_id       BIGINT NOT NULL REFERENCES users(id),
    lease_id        BIGINT NOT NULL REFERENCES leases(id),
    property_id     BIGINT NOT NULL REFERENCES properties(id),
    unit_space_id   BIGINT NOT NULL REFERENCES unit_spaces(id),
    amount          DECIMAL(10,2) NOT NULL,
    payment_type    VARCHAR(20) NOT NULL DEFAULT 'RENT',  -- RENT, DEPOSIT, LATE_FEE
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    due_date        DATE NOT NULL,
    paid_at         TIMESTAMP,
    stripe_payment_intent_id VARCHAR(255),
    stripe_checkout_session_id VARCHAR(255),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_tenant ON payments(tenant_id);
CREATE INDEX idx_payments_lease ON payments(lease_id);

-- ============================================================
-- MOVE-OUT REQUESTS
-- ============================================================

CREATE TABLE move_out_requests (
    id              BIGSERIAL PRIMARY KEY,
    tenant_id       BIGINT NOT NULL REFERENCES users(id),
    lease_id        BIGINT NOT NULL REFERENCES leases(id),
    requested_date  DATE NOT NULL,
    reason          TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'SUBMITTED',
    reviewed_by     BIGINT REFERENCES users(id),
    reviewed_at     TIMESTAMP,
    review_comment  TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_move_out_tenant ON move_out_requests(tenant_id);
CREATE INDEX idx_move_out_lease ON move_out_requests(lease_id);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    message         TEXT NOT NULL,
    type            VARCHAR(30) NOT NULL,            -- INVITE, LEASE, PAYMENT, DOCUMENT, MOVE_OUT, SYSTEM
    reference_id    BIGINT,
    reference_type  VARCHAR(30),
    read            BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, read) WHERE read = FALSE;

-- ============================================================
-- AUDIT LOG
-- ============================================================

CREATE TABLE audit_logs (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT REFERENCES users(id),
    action          VARCHAR(100) NOT NULL,
    entity_type     VARCHAR(50) NOT NULL,
    entity_id       BIGINT,
    details         JSONB,
    ip_address      VARCHAR(50),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
