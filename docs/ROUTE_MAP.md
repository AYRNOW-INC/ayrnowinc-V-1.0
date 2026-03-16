# AYRNOW — Route Map

## Auth Flow (unauthenticated)
```
/ (SplashWelcomeScreen)
├── → /login (LoginScreen)
│   ├── → /forgot-password (ForgotPasswordScreen)
│   └── → /register (RegisterScreen, 2-step)
└── → /register (RegisterScreen)
```

## Landlord Shell (authenticated, LANDLORD role)
```
LandlordShell [Bottom Nav]
├── Tab 0: Dashboard (LandlordDashboard)
│   ├── Empty state → "Add My First Property" → AddPropertyScreen
│   └── Populated state → Quick Actions → (future navigation targets)
├── Tab 1: Properties (PropertyListScreen)
│   ├── Empty state → "Add First Property" → AddPropertyScreen
│   ├── Property card → PropertyDetailScreen
│   │   ├── Unit row → EditUnitScreen
│   │   ├── "+ Add New Unit" → EditUnitScreen (create mode)
│   │   └── Menu → LeaseSettingsScreen (view/edit toggle)
│   └── FAB → AddPropertyScreen
│       └── Steps 1-3 → Success → back to list
├── Tab 2: Leases (LeaseListScreen)
│   ├── Empty state → "Create First Lease" → CreateLeaseWizard
│   ├── Lease card → Detail bottom sheet
│   │   ├── "Send to Sign" action
│   │   └── "Edit" action
│   └── FAB → CreateLeaseWizard (3-step)
├── Tab 3: Payments (LandlordPaymentScreen)
│   ├── Empty state → "Connect Payment Provider"
│   └── Populated → per-property payment list
└── Tab 4: Account (AccountScreen)
    ├── Profile card → "Edit Profile" (placeholder)
    ├── Business & Finance section
    ├── Preferences section
    ├── Legal & Support section
    └── Sign Out → back to auth flow
```

## Tenant Shell (authenticated, TENANT role)
```
TenantShell [Bottom Nav]
├── Tab 0: Home (TenantDashboard)
│   ├── Pre-active state (no lease) → countdown + checklist
│   └── Active state → payment banner + quick actions
├── Tab 1: Lease (TenantLeaseScreen)
│   ├── No lease → empty state
│   └── Has lease → detail card + sign button + download PDF
├── Tab 2: Pay (TenantPaymentScreen)
│   ├── No payments → empty state
│   └── Payment list → "Pay" → Stripe Checkout (external)
├── Tab 3: Docs (DocumentScreen)
│   ├── Progress bar → required document slots
│   ├── Upload buttons → file picker → API upload
│   └── Status badges (APPROVED/UNDER_REVIEW/MISSING)
└── Tab 4: Account (AccountScreen)
    ├── Financials section
    ├── Property section
    ├── Preferences section
    └── Sign Out
```

## Standalone Screens (pushed as full routes)
```
InviteScreen → (from landlord dashboard/properties)
├── List view (pending invites)
└── Send form → InviteTenantScreen → Sent success

MoveOutScreen → (from tenant/landlord)
├── Landlord view → approve/reject cards
└── Tenant view → list + FAB → MoveOutForm

NotificationsScreen → (from app bar bell icon)
└── Grouped notification list with mark-read

LandlordOnboardingScreen → (from dashboard/account)
└── Setup checklist with progress
```
