# AYRNOW — API Overview

Base URL: `http://localhost:8080/api`

All authenticated endpoints require: `Authorization: Bearer <jwt_token>`

## Auth (public)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user (landlord or tenant) |
| POST | `/auth/login` | Login, returns JWT access + refresh tokens |
| POST | `/auth/refresh` | Refresh expired access token |

## Users (authenticated)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/me` | Get current user profile |
| PUT | `/users/me` | Update profile (name, phone, landlord/tenant fields) |

## Properties (LANDLORD only)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/properties` | List landlord's properties |
| POST | `/properties` | Create property (supports `initialUnitCount` for auto-generation) |
| GET | `/properties/:id` | Get property detail with units and lease settings |
| PUT | `/properties/:id` | Update property |
| DELETE | `/properties/:id` | Delete property (cascades to units) |

## Units (LANDLORD only)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/properties/:id/units` | List units for a property |
| POST | `/properties/:id/units` | Create unit |
| PUT | `/properties/:id/units/:uid` | Update unit |
| DELETE | `/properties/:id/units/:uid` | Delete unit |

## Lease Settings (LANDLORD only)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/properties/:id/lease-settings` | Get property lease defaults |
| PUT | `/properties/:id/lease-settings` | Update lease defaults |

## Invitations
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/invitations` | LANDLORD | Create invitation (generates invite code) |
| GET | `/invitations` | LANDLORD | List landlord's invitations |
| DELETE | `/invitations/:id` | LANDLORD | Cancel invitation |
| GET | `/invitations/accept/:code` | Public | View invitation by code |
| POST | `/invitations/accept/:code` | Authenticated | Accept invitation |

## Leases
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/leases` | LANDLORD | Create lease (auto-creates signature records) |
| GET | `/leases/landlord` | LANDLORD | List landlord's leases |
| GET | `/leases/tenant` | TENANT | List tenant's leases |
| GET | `/leases/:id` | Either | Get lease detail |
| POST | `/leases/:id/send` | LANDLORD | Send lease for signing (DRAFT → SENT_FOR_SIGNING) |
| POST | `/leases/:id/sign` | Either | Sign lease (updates status based on who signed) |

## Documents
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/documents` | TENANT | Upload document (multipart: file + documentType + leaseId) |
| GET | `/documents/tenant` | TENANT | List tenant's documents |
| GET | `/documents/lease/:id` | Either | List documents for a lease |
| PUT | `/documents/:id/review` | LANDLORD | Review document (APPROVED/REJECTED + comment) |
| GET | `/documents/:id/download` | Either | Download document file |

## Payments
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/payments/tenant` | TENANT | List tenant's payments |
| GET | `/payments/lease/:id` | Either | List payments for a lease |
| GET | `/payments/property/:id` | LANDLORD | List payments for a property |
| POST | `/payments/:id/checkout` | TENANT | Create Stripe Checkout session |

## Move-Out
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/move-out` | TENANT | Submit move-out request |
| GET | `/move-out/tenant` | TENANT | List tenant's move-out requests |
| GET | `/move-out/landlord` | LANDLORD | List landlord's incoming requests |
| PUT | `/move-out/:id/review` | LANDLORD | Approve/reject request |

## Dashboard
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/dashboard/landlord` | LANDLORD | Landlord stats (properties, units, revenue, etc.) |
| GET | `/dashboard/tenant` | TENANT | Tenant stats (amount due, lease status, etc.) |

## Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications` | All notifications |
| GET | `/notifications/unread` | Unread only |
| GET | `/notifications/unread/count` | Unread count |
| PUT | `/notifications/:id/read` | Mark one as read |
| PUT | `/notifications/read-all` | Mark all as read |

## Webhooks (public, signature-verified)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/webhooks/stripe` | Stripe payment webhook (checkout.session.completed/expired) |

## Health
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Returns `{"app":"AYRNOW","status":"UP"}` |

## Error Responses
All errors return JSON: `{"error": "message"}`
- 400: Validation error or bad request
- 403: Not authenticated or not authorized
- 500: Internal server error
