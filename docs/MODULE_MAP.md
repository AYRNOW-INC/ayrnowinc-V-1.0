# AYRNOW — Module Map

## Backend Modules (Spring Boot Monolith)

All modules live inside `com.ayrnow.*` under a single Spring Boot application.

| Module | Package | Controller | Service | Repository | Entity |
|--------|---------|------------|---------|------------|--------|
| auth-integration | security/ | AuthController | AuthService | UserRepository, RoleRepository | User, Role |
| user-profile | controller/ | UserController | UserService | LandlordProfileRepository, TenantProfileRepository | LandlordProfile, TenantProfile |
| property | controller/ | PropertyController | PropertyService | PropertyRepository | Property |
| unit-space | controller/ | UnitSpaceController | UnitSpaceService | UnitSpaceRepository | UnitSpace |
| invite | controller/ | InvitationController | InvitationService | InvitationRepository | Invitation |
| lease | controller/ | LeaseController | LeaseService | LeaseRepository, LeaseSignatureRepository | Lease, LeaseSignature |
| lease-settings | controller/ | LeaseSettingsController | LeaseSettingsService | LeaseSettingsRepository | LeaseSettings |
| document | controller/ | DocumentController | DocumentService | TenantDocumentRepository | TenantDocument |
| payment | controller/ | PaymentController | PaymentService | PaymentRepository | Payment |
| move-out | controller/ | MoveOutController | MoveOutService | MoveOutRequestRepository | MoveOutRequest |
| dashboard | controller/ | DashboardController | DashboardService | (uses multiple repos) | — |
| webhook | controller/ | WebhookController | PaymentService | — | — |
| notification | controller/ | NotificationController | NotificationService | NotificationRepository | Notification |
| audit | service/ | — | AuditService | AuditLogRepository | AuditLog |

## Frontend Modules (Flutter)

| Module | Directory | Screens |
|--------|-----------|---------|
| Auth | screens/auth/ | SplashWelcomeScreen, LoginScreen, RegisterScreen, ForgotPasswordScreen |
| Landlord | screens/landlord/ | LandlordDashboard, PropertyListScreen, PropertyDetailScreen, AddPropertyScreen, EditUnitScreen, LeaseListScreen, LandlordPaymentScreen, AccountScreen, OnboardingScreen |
| Tenant | screens/tenant/ | TenantDashboard, TenantLeaseScreen, TenantPaymentScreen, DocumentScreen |
| Shared | screens/shared/ | InviteScreen, MoveOutScreen, NotificationsScreen |
| Theme | theme/ | AppTheme, AppColors |
| Services | services/ | ApiService |
| State | providers/ | AuthProvider |

## Cross-Module Dependencies

```
AuthProvider → ApiService → Backend Auth API
All screens → ApiService → Backend REST APIs
LandlordShell → [Dashboard, Properties, Leases, Payments, Account]
TenantShell → [Dashboard, Lease, Payments, Docs, Account]
PropertyDetailScreen → EditUnitScreen, LeaseSettingsScreen
LeaseListScreen → CreateLeaseWizard
InviteScreen → InviteTenantScreen
MoveOutScreen → MoveOutForm
```
