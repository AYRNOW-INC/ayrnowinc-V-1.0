# AYRNOW — Database Schema Overview

PostgreSQL 16 | Flyway V1 Migration

## Tables (16)

### Core Identity
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `users` | All app users | id, external_id (future social OAuth provider link), email, first_name, last_name, status |
| `roles` | User role assignments | user_id, role (LANDLORD/TENANT) |
| `landlord_profiles` | Landlord-specific data | user_id, company_name, business_address, tax_id |
| `tenant_profiles` | Tenant-specific data | user_id, date_of_birth, ssn_last_four, employer, annual_income |

### Property Management
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `properties` | Rental properties | landlord_id, name, property_type, address, city, state, postal_code, status |
| `unit_spaces` | Rentable units within properties | property_id, name, unit_type, floor, bedrooms, monthly_rent, status (VACANT/OCCUPIED) |

### Tenant Onboarding
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `invitations` | Tenant invitations | landlord_id, unit_space_id, tenant_email, invite_code, status, expires_at, tenant_id |

### Lease Management
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `lease_settings` | Property-level lease defaults | property_id, default_lease_term_months, default_monthly_rent, payment_due_day, grace_period_days, late_fee |
| `leases` | Active lease agreements | property_id, unit_space_id, landlord_id, tenant_id, monthly_rent, start_date, end_date, status |
| `lease_signatures` | Signature tracking | lease_id, signer_id, signer_role, signed, signed_at, ip_address |

### Documents
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `tenant_documents` | Uploaded tenant documents | tenant_id, lease_id, document_type (ID/PROOF_OF_INCOME/BACKGROUND_CHECK), file_path, status |

### Payments
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `payments` | Payment records | tenant_id, lease_id, property_id, unit_space_id, amount, payment_type, status, stripe_checkout_session_id |

### Move-Out
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `move_out_requests` | Tenant move-out requests | tenant_id, lease_id, requested_date, reason, status, reviewed_by |

### System
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `notifications` | In-app notifications | user_id, title, message, type, reference_id, read |
| `audit_logs` | Audit trail | user_id, action, entity_type, entity_id, details (JSONB) |
| `flyway_schema_history` | Migration tracking | (managed by Flyway) |

## Key Relationships
```
users 1--* roles
users 1--1 landlord_profiles
users 1--1 tenant_profiles
users 1--* properties (as landlord)
properties 1--* unit_spaces
properties 1--1 lease_settings
unit_spaces 1--* invitations
leases *--1 properties, unit_spaces, users (landlord), users (tenant)
leases 1--* lease_signatures
leases 1--* payments
leases 1--* tenant_documents
leases 1--* move_out_requests
users 1--* notifications
```

## Status Enums

| Entity | Statuses |
|--------|----------|
| Account | ACTIVE, INVITED, SUSPENDED, PENDING |
| Invitation | PENDING, SENT, OPENED, ACCEPTED, EXPIRED, CANCELLED |
| Lease | DRAFT, SENT_FOR_SIGNING, LANDLORD_SIGNED, TENANT_SIGNED, FULLY_EXECUTED, EXPIRED, TERMINATED |
| Document | MISSING, UPLOADED, UNDER_REVIEW, APPROVED, REJECTED |
| Payment | PENDING, SUCCESSFUL, FAILED, OVERDUE, REFUNDED |
| Move-Out | DRAFT, SUBMITTED, UNDER_REVIEW, APPROVED, REJECTED, COMPLETED |
