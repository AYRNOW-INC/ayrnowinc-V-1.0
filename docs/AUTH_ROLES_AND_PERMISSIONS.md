# Auth Roles and Permissions

Role definitions, access rules, and enforcement for AYRNOW.

---

## Roles

AYRNOW has two roles in the MVP. Roles are stored in the `roles` table and embedded in JWT claims.

### LANDLORD

Assigned when a user registers with `role: "LANDLORD"`.

**Can access:**
- Property CRUD (`/api/properties/**`)
- Unit/Space CRUD (`/api/units/**`)
- Lease settings management (`/api/lease-settings/**`)
- Lease creation and management (`/api/leases/**`)
- Tenant invitations — create and manage (`/api/invitations/**`)
- Tenant document review (`/api/documents/**` — read/review only)
- Payment history viewing (`/api/payments/**` — read only)
- Move-out request review and approve/reject (`/api/move-out/**`)
- Notifications (`/api/notifications/**`)
- Dashboard — landlord view (`/api/dashboard/**`)
- Own profile (`/api/users/me`)

### TENANT

Assigned when a user registers with `role: "TENANT"`.

**Can access:**
- Assigned property and unit details (read only)
- Lease viewing and signing (`/api/leases/**` — own leases)
- Document upload (`/api/documents/**` — own documents)
- Rent payment (`/api/payments/**` — create and view own)
- Move-out request creation (`/api/move-out/**` — own requests)
- Notifications (`/api/notifications/**`)
- Dashboard — tenant view (`/api/dashboard/**`)
- Own profile (`/api/users/me`)

**Cannot access:**
- Property creation/editing
- Unit management
- Lease settings
- Invitation creation
- Other tenants' data
- Approve/reject actions on move-out requests

---

## Role Assignment

- Role is chosen by the user during registration (LANDLORD or TENANT)
- Role is stored in the `roles` table with a foreign key to `users`
- Role is embedded in the JWT at token issuance
- **No role switching.** A user cannot change from LANDLORD to TENANT or vice versa after registration
- A single user has exactly one role

---

## Backend Enforcement

### JWT-Level
The role claim in the JWT is checked by `JwtAuthFilter` on every request. The authenticated principal includes the role as a granted authority.

### Controller-Level
Controllers enforce role access using:
- `@PreAuthorize("hasAuthority('LANDLORD')")` for landlord-only endpoints
- `@PreAuthorize("hasAuthority('TENANT')")` for tenant-only endpoints
- No annotation for endpoints accessible by both roles (e.g., `/api/auth/me`)

### Service-Level
Services enforce data ownership:
- Landlords can only manage their own properties, units, leases
- Tenants can only view/act on their own assigned data
- UserId is extracted from the JWT, never from request body for authorization

### No Frontend-Only Authorization
The Flutter app hides UI elements based on role for UX clarity, but all actual access control happens on the backend. A tampered frontend request to a landlord endpoint from a tenant account will be rejected by the backend.

---

## Role-Endpoint Matrix

| Endpoint Group | LANDLORD | TENANT |
|---|---|---|
| /api/auth/** | Yes | Yes |
| /api/users/me | Yes | Yes |
| /api/properties/** | Full CRUD | Read (assigned only) |
| /api/units/** | Full CRUD | Read (assigned only) |
| /api/invitations/** | Create/Manage | Accept only |
| /api/lease-settings/** | Full CRUD | No |
| /api/leases/** | Create/Manage/Sign | View/Sign (own) |
| /api/documents/** | Review | Upload/View (own) |
| /api/payments/** | View (all tenants) | Create/View (own) |
| /api/move-out/** | Review/Approve/Reject | Create (own) |
| /api/notifications/** | Own | Own |
| /api/dashboard/** | Landlord view | Tenant view |

---

## Future Roles

These roles are not implemented in the MVP but are planned:

- **CONTRACTOR** — Maintenance vendor access to assigned work orders
- **SECURITY_GUARD** — Visitor check-in/approval for gated properties
- **PROPERTY_MANAGER** — Delegated management on behalf of a landlord
- **INVESTOR** — Read-only financial/occupancy views

When added, these will follow the same pattern: stored in `roles` table, embedded in JWT, enforced on backend.
