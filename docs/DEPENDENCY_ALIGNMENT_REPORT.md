# AYRNOW — Dependency Alignment Report

Verified against CLAUDE.md and dependency stack docs.

## Stack Compliance

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Flutter frontend | COMPLIANT | `pubspec.yaml` — Flutter SDK, 20 Dart screens |
| Spring Boot backend | COMPLIANT | `pom.xml` — spring-boot-starter-parent 3.4.4 |
| PostgreSQL database | COMPLIANT | `application.properties` — PostgreSQL driver, 16 tables via Flyway |
| Flyway migrations | COMPLIANT | `V1__Initial_schema.sql` — runs on startup |
| Monolith architecture | COMPLIANT | Single `AyrnowApplication.java` entry point, single JAR |
| No Docker | COMPLIANT | No Dockerfile, no docker-compose, no container references anywhere |

## Integration Compliance

| Integration | Required Boundary | Status | Detail |
|-------------|------------------|--------|--------|
| Native Auth | AYRNOW owns identity, sessions, roles, and permissions | COMPLIANT | Native JWT auth built with login, register, token refresh. Social OAuth deferred. |
| OpenSign → signing | OpenSign owns signature capture; AYRNOW owns lease lifecycle | PARTIAL | `lease.opensignDocId` field exists. Internal sign endpoint works. OpenSign API client not built. Webhook endpoint not created. Docs ready. |
| Stripe → payments | Stripe owns payment execution; AYRNOW owns ledger/status | COMPLIANT | `stripe-java` 28.2.0 in pom.xml. Checkout session creation works. Webhook handler (`/api/webhooks/stripe`) verifies signature, handles `checkout.session.completed/expired`. |
| PostgreSQL → data | Source of truth for all AYRNOW business data | COMPLIANT | 14 business tables + flyway history + audit_logs. All entities mapped via JPA. |
| Spring Boot → API hub | All internal APIs, validation, orchestration | COMPLIANT | 14 controllers, 12 services, JWT security, CORS config, validation annotations. |

## Entity/Data Model Compliance

| Required Entity | Status | Table |
|-----------------|--------|-------|
| User | COMPLIANT | `users` |
| Role | COMPLIANT | `roles` |
| LandlordProfile | COMPLIANT | `landlord_profiles` |
| TenantProfile | COMPLIANT | `tenant_profiles` |
| Property | COMPLIANT | `properties` |
| UnitSpace | COMPLIANT | `unit_spaces` |
| Invitation | COMPLIANT | `invitations` |
| Lease | COMPLIANT | `leases` |
| LeaseSignature | COMPLIANT | `lease_signatures` |
| LeaseSettings | COMPLIANT | `lease_settings` |
| TenantDocument | COMPLIANT | `tenant_documents` |
| Payment | COMPLIANT | `payments` |
| MoveOutRequest | COMPLIANT | `move_out_requests` |
| Notification | COMPLIANT | `notifications` |
| AuditLog | COMPLIANT | `audit_logs` |

## Required Module Compliance

| Module | Status | Implementation |
|--------|--------|----------------|
| auth-integration | COMPLIANT | AuthController + AuthService + JwtProvider + JwtAuthFilter |
| user-profile | COMPLIANT | UserController + UserService |
| property | COMPLIANT | PropertyController + PropertyService |
| unit-space | COMPLIANT | UnitSpaceController + UnitSpaceService |
| invite | COMPLIANT | InvitationController + InvitationService |
| lease | COMPLIANT | LeaseController + LeaseService |
| lease-settings | COMPLIANT | LeaseSettingsController + LeaseSettingsService |
| document | COMPLIANT | DocumentController + DocumentService |
| payment | COMPLIANT | PaymentController + PaymentService |
| move-out | COMPLIANT | MoveOutController + MoveOutService |
| dashboard | COMPLIANT | DashboardController + DashboardService |
| webhook | COMPLIANT | WebhookController (Stripe). OpenSign webhook NOT YET BUILT. |
| audit | COMPLIANT | AuditService + AuditLogRepository |
| notification | COMPLIANT | NotificationController + NotificationService |

## Gaps Requiring Action

| Gap | Severity | Fix |
|-----|----------|-----|
| Social OAuth not implemented | LOW (for MVP) | Add Google/Apple sign-in when needed. Native JWT auth is fully functional. |
| OpenSign API client not built | LOW (for MVP) | Build `OpenSignClient` service when credentials available. Add webhook endpoint. See `docs/OPENSIGN_INTEGRATION.md`. |
| OpenSign webhook endpoint missing | MEDIUM | Create `POST /api/webhooks/opensign` in `WebhookController`. |
| Backend unit tests empty | MEDIUM | Write tests for critical services (AuthService, PropertyService, LeaseService). |
| `go_router` in pubspec but not used | LOW | Currently using `Navigator.push`. Can migrate to `go_router` for declarative routing. |
