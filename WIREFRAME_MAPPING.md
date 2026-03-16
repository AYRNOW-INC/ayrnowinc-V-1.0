# AYRNOW Wireframe-to-Screen Mapping & Audit

## Confirmed Stack
- Frontend: Flutter
- Backend: Spring Boot
- Database: PostgreSQL
- Migrations: Flyway
- Architecture: Monolith
- Docker: None

## Source of Truth (Priority Order)
1. PNG wireframes (54 screens) — `/AYRNOW/wireframe/`
2. React example screens — **NOT FOUND** (no React folder exists in workspace)
3. AYRNOW docs — `CLAUDE.md`, `knowledge.md`, `.docx` files
4. Existing generated code — `ayrnow-mvp/frontend/lib/`

---

## WIREFRAME-TO-SCREEN MAPPING

### A. AUTH & ONBOARDING (4 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| A1 | `Splash _ Welcome.png` | `_SplashScreen` (in main.dart) | Blue icon, "Simplify Your Rental Journey", Login button, Create Account button, "TRUSTED BY 10,000+ LANDLORDS" | **MISMATCH** |
| A2 | `Login.png` | `LoginScreen` | "Welcome back" header, Email or Phone field w/ mail icon, Password w/ lock icon + visibility toggle, "Sign In" button, "OR CONTINUE WITH" divider, Google button, Apple button, "New to AYRNOW? Create an account", "Forgot password?" link | **MISMATCH** |
| A3 | `Register _ Account Type.png` | `_RegisterSheet` (bottom sheet) | Multi-step "STEP 2 OF 4", "How will you use AYRNOW?", Landlord card (selected, blue highlight, tags: Unlimited Properties, Lease Automation, Rent Collection), Tenant card (tags: Easy Rent Payments, Digital Leases), "SECURE & VERIFIED" badge, Continue button | **MISMATCH** |
| A4 | `Forgot Password.png` | **MISSING** | "Reset Password" app bar, key icon, "Forgot Password?" title, email/phone field, "Send Reset Link" button, "Contact Support" link, "Return to Login" | **MISSING** |

### B. LANDLORD DASHBOARD & ACCOUNT (5 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| B1 | `Landlord Dashboard (Empty).png` | `LandlordDashboard` | 4 stat cards (Properties, Tenants, Active Leases, Monthly Rent), "Start Your Portfolio" CTA with building icon, "Add My First Property" button, Quick Setup Guide (1. Create Property Record, 2. Configure Lease Rules), bottom nav: Dashboard/Properties/Leases/Payments/Account | **MISMATCH** |
| B2 | `Landlord Dashboard (Populated).png` | `LandlordDashboard` | "Welcome back, Marcus" greeting, $18,420 Rent Collected (12% vs last mo), 94% Occupancy, 03 Pending Invites, 18 Active Leases, Quick Actions grid (Add Property, Invite Tenant, Create Lease), Recent Activity feed with avatars, "Automate Rent Reminders" promo card | **MISMATCH** |
| B3 | `Landlord Account Setup.png` | **MISSING** | Onboarding checklist with progress (1 of 3, 33%), steps: Account Verified, Add Your First Property, Invite Your Tenants, Setup Digital Leases, "Watch Video Guide" | **MISSING** |
| B4 | `Landlord Account Settings.png` | `AccountScreen` | Profile card (avatar, name, email, "Edit Profile"), Business & Finance section (Payment Provider/Stripe, Tax Information, Subscription Plan), Preferences (Notifications, Security), Legal & Support (Terms, Help Center, Privacy Policy), Sign Out button, version number | **MISMATCH** |
| B5 | `Landlord Account Edit.png` | **MISSING** | "Edit Preferences" screen, avatar with camera icon, Contact Information (Full Name, Email, Phone), Notification toggles (Push, Email Summaries, SMS Reminders), Lease Preferences (Default Template, Payment Provider Settings), "Save All Changes" / "Discard Changes" | **MISSING** |

### C. PROPERTY MANAGEMENT (8 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| C1 | `Properties List (Empty).png` | `PropertyListScreen` (empty state) | "Start Your Portfolio" with building icon, "HOW IT WORKS" guide (1. Property Details, 2. Define Units, 3. Invite & Lease), "+ Add First Property" button | **MISMATCH** |
| C2 | `Properties List (Populated).png` | `PropertyListScreen` (list) | Search bar, filter tabs (All, Residential, Commercial), sort option, property cards with IMAGE, occupancy % badge, address, unit count, occupancy %, bottom actions (View, Edit, Lease) | **MISMATCH** |
| C3 | `Property Details.png` | `_PropertyDetailScreen` | Hero image with "Active Property" badge, address overlay, 3 stat circles (92% Occupancy, 11/12 Units, $18,450 Revenue), tab bar (Units, Tenants, Leases, Payments), Unit Inventory list with unit badges, tenant avatars, rent amounts, status chips (Occupied/Vacant), "+ Add New Unit" | **MISMATCH** |
| C4 | `Add Property: Basic Info.png` | `_AddPropertySheet` (bottom sheet) | Full-screen "Add Property" with back arrow, "STEP 1 OF 3" progress bar (33%), sections: IDENTITY (Property Name, Property Type icons: Residential/Commercial/Industrial/Other), LOCATION (Street Address, City, State, Zip), NARRATIVE (Description), "Next: Property Structure" button | **MISMATCH** |
| C5 | `Add Property: Structure Setup.png` | Not implemented (auto-generated) | "Step 2: Define Structure" (66%), property name shown, "How is it divided?" section, Total Units + Total Floors inputs, Common Features toggles (Parking, Storage, Amenity Areas), "Review Property" button | **MISSING** |
| C6 | `Add Property: Review & Save.png` | Not implemented | "Step 3 of 3" review, property image, "Ready to Publish" badge, Location Details, Unit Composition breakdown (1-Bed: 6, 2-Bed: 4, Studio: 2), "Edit Layout" option, "Save & Create Property" + "Save as Draft" | **MISSING** |
| C7 | `Unit _ Space List.png` | Embedded in `_PropertyDetailScreen` | "Unit Management" with search/filter, tabs (All, Occupied, Vacant, Maintenance), unit cards with unit number badge, type, rent, tenant avatar, status chip, action buttons (Edit, Invite, Lease), overdue rent warning, Occupancy Rate stat, "Full Report" link | **MISMATCH** |
| C8 | `Add _ Edit Unit or Space.png` | Dialog in `_PropertyDetailScreen` | Full "Edit Unit" screen, Unit Identity (Name/Number, Floor Level), Rent & Deposit (Monthly Rent, Security Deposit), Utility Inclusions toggles (Electricity, Water, Internet, Trash, Gas/Heating), Internal Notes textarea, "Mark as ready for leasing" checkbox, "Save Unit Details" button | **MISMATCH** |
| C9 | `Property Created Success.png` | Not implemented | Success screen with green check, "Property Created!" title, Property Summary card, "View Property" button, "Invite Your First Tenant" button, "+ Add Another Property" link | **MISSING** |

### D. INVITE FLOW (6 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| D1 | `Invite Tenant.png` | `InviteScreen` (bottom sheet) | Full screen: Recipient Details (Name, Email), Property Assignment (Property & Unit dropdown, Proposed Start Date), Personalized Message (tone chips: Professional/Friendly/Urgent, message preview), Expiry Preview (7 days), "Send Secure Invitation" button | **MISMATCH** |
| D2 | `Invite Sent Confirmation.png` | Not implemented | Success screen: "Invite Sent Successfully!", tenant info card (avatar, email, status), Property & Unit, Expires in 7 days, "View Invite Status" button, "Resend Invitation", "Copy Direct Link" | **MISSING** |
| D3 | `Invite Expired_Invalid.png` | Not implemented | "Access Denied" / "Invitation Expired" with shield icon, property details, landlord info, "Request New Invitation" + "Contact Landlord Directly" buttons | **MISSING** |
| D4 | `Pending Invites.png` | Embedded in `AccountScreen` | Dedicated screen: filter tabs (Pending, Expiring Soon), search, invite cards with tenant avatar/name/email, property/unit info, sent date, days left, Cancel/Resend buttons, "Managing Expiry" info card | **MISMATCH** |
| D5 | `Tenant Invite Acceptance.png` | Not implemented | Tenant-facing: "You're Invited!" with property image, property/unit details, landlord avatar, monthly rent, move-in date, "Accept & Create Account" button, "Log In to Existing Account" link, trust badges | **MISSING** |
| D6 | `Tenant Invite Verification.png` | Not implemented | "Verify Invite" with property image, unit details, landlord info, Security Setup section (email, create password, confirm password, requirements list), "Accept Invite & Continue" button | **MISSING** |

### E. LEASE MANAGEMENT (10 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| E1 | `Lease Settings Overview.png` | `_LeaseSettingsSheet` (bottom sheet) | Full screen: "Global Lease Defaults" header, Financial Terms (Rent Due Day, Security Deposit, Late Fee), General Policies (Grace Period, Occupancy Limit), Standard Clauses list with Active/Optional badges, "+ Manage Custom Clauses", "Update Global Settings" button | **MISMATCH** |
| E2 | `Lease Settings: Edit.png` | `_LeaseSettingsSheet` | Full screen: General Terms (Default Lease Term + auto-renewal toggle), Rent & Deposit fields, Rent Due Day, Late Fee Settings (Grace Period Days, Late Fee Amount, Policy Preview), Standard Clauses (editable text blocks, "+ Add Custom Clause"), Internal Admin Notes, "Save Global Defaults" | **MISMATCH** |
| E3 | `Create Lease: Select Property.png` | `_CreateLeaseSheet` | Step 1 of 5: "Select Property & Unit" with search + filter, property cards with images, address, unit count, available count | **MISMATCH** |
| E4 | `Create Lease: Tenant Information.png` | `_CreateLeaseSheet` | Step 2 of 5: "Select Tenant" with search, tenant list with avatars/email/phone, radio selection, "Invite a New Tenant" option with "Create new profile" link | **MISMATCH** |
| E5 | `Create Lease: Lease Terms.png` | `_CreateLeaseSheet` | Step 3 of 5: Lease Period (Start Date + End Date pickers), Financials (Monthly Rent, Security Deposit), Billing Details (Rent Due Day dropdown), Pro-rated Rent info, Lease Summary card ($28,800 total), "Continue to Clauses" + "Save Progress as Draft" | **MISMATCH** |
| E6 | `Create Lease: Clauses & Notes.png` | Not implemented | Step 4 of 5: Clause Templates (Pet Policy, Late Fees cards with +Add), Active Clauses list (editable), Internal Notes (private to landlord), "Review Lease" button | **MISSING** |
| E7 | `Create Lease: Review.png` | Not implemented | Final Step: step progress dots, "Lease Agreement Ready" badge, sections (Property & Unit, Tenant Details, Lease Terms, Clauses & Notes) each with Edit link, "Send for Signature" button, "PDF Preview" + "Save Draft" | **MISSING** |
| E8 | `Leases List (Empty).png` | `LeaseListScreen` (empty state) | "No active leases yet", "HOW IT WORKS" steps (Configure Terms, Digital E-Signing, Secure Management), "+ Create First Lease" button, "Leasing Guide" link | **MISMATCH** |
| E9 | `Leases List (Populated).png` | `LeaseListScreen` (list) | "LEASE PORTFOLIO" header with count, filter tabs (All, Drafts, Sent, Active), lease cards with property image, status badge (Executed/Sent/Draft/Signed), tenant avatar, rent, term, "View"/"PDF" actions | **MISMATCH** |
| E10 | `Lease Details (Draft).png` | Bottom sheet in `LeaseListScreen` | Full screen: "Draft Mode" badge, property image, address, move-in countdown, Tenant card (avatar, email, "Edit Contact"), Lease Terms (Rent, Deposit, Start Date, Duration), Review & Files (PDF Preview, Clauses & Rules, Download Assets), Landlord Notes, Edit + "Send to Sign" buttons | **MISMATCH** |

### F. SIGNING FLOW (5 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| F1 | `Generated Lease Ready.png` | Not implemented | "Lease Ready" screen: PDF file info (name, size), "Preview Full PDF", Lease Details, Required Signers list with Verified badges, "Send to Sign" button, "Edit" option | **MISSING** |
| F2 | `Lease Signing.png` | Not implemented | "E-Sign Lease" screen: Document Summary (property, unit, term, rent), Signer Identity card with "ID VERIFIED BY AYRNOW", signature pad ("Draw your signature here"), consent checkboxes (Lease Agreement, Electronic Disclosure), "Sign & Confirm Lease" button | **MISSING** |
| F3 | `Lease Signing Status.png` | Not implemented | "Signing Status" with property image, progress bar (75%), Timeline Tracking (Drafted, Sent, Landlord Signed, Tenant Signature Required with "Send Reminder", Fully Executed), Current Document (PDF with Download/View), "View Metadata" + "Update Lease" | **MISSING** |
| F4 | `Lease Signed Success.png` | Not implemented | "Lease Signed!" success, signed PDF copy info, "Finalize Onboarding" actions: Setup Rent Payments (Required), Upload Remaining Docs (Required), "Go to Dashboard" button | **MISSING** |
| F5 | `Lease Review.png` | Not implemented | "Review Lease" with highlights (Monthly Rent, Lease Term, Security Deposit, Move-in Date), PDF document preview with page indicator, Required Actions checklist (Confirm personal details, Review deposit terms, Read house rules), "Go to Lease Signing" button | **MISSING** |

### G. VIEW LEASE (tenant) (1 wireframe)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| G1 | `View Lease.png` | `TenantLeaseScreen` | "My Lease" with Active badge, rent amount, due day, address, term dates, "Download PDF" button, Document Preview with page indicator + zoom, Lease Details cards (Security Deposit w/ "Held in Escrow", Notice Period, Utility Responsibility), "Contact" landlord option, bottom nav: Home/Lease/Pay/Docs/Account | **MISMATCH** |

### H. PAYMENTS (5 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| H1 | `Landlord Payments (Empty).png` | `LandlordPaymentScreen` | "Unlock Effortless Rent Collection", "Connect Payment Provider" button, HOW IT WORKS steps (Secure Connection, Set Billing Rules, Start Collecting), security badges (PCI COMPLIANT, STRIPE VERIFIED, AES-256 BIT) | **MISMATCH** |
| H2 | `Landlord Payments (Populated).png` | `LandlordPaymentScreen` | Total Collected (month), Outstanding + Next Payout, search + filter tabs (All, Pending, Paid, Overdue), transaction list with tenant avatars, amounts, status badges (Paid/Overdue/Pending), "View Ledger" link | **MISMATCH** |
| H3 | `Payment Ledger.png` | Not implemented | "Ledger Detail" with running balance, paid/outstanding breakdown, statement period, tenant info (signed badge), activity list with categorized entries (+/- amounts, colored), totals (Invoiced/Received/Outstanding), "Export PDF" | **MISSING** |
| H4 | `Rent Payment.png` | `TenantPaymentScreen` | Full screen: Payment Method cards (Visa, Bank), "+ Add New Payment Method", Transaction Summary (Rent, Maintenance Fee, Convenience Fee, Total), "SECURE SSL ENCRYPTED", Pay button with amount | **MISMATCH** |
| H5 | `Rent Payment Success.png` | Not implemented | "Payment Successful!" with transaction ID, property/unit/date/method details, Payment Summary (Base Rent, Utility Surcharge, Total), "Save PDF"/"Share" buttons, "Go to Dashboard", "View Lease Agreement" | **MISSING** |

### I. DOCUMENTS (2 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| I1 | `Document Upload_Status.png` | `DocumentScreen` | "My Documents" with submission progress (2 of 4, 50%), Required Documents list (Gov ID - Approved, Proof of Income - Under Review, Renters Insurance - Missing with Upload button, Pet Vaccinations - Optional with Upload), "+ Additional Support Docs" section, "Contact Landlord Support" | **MISMATCH** |
| I2 | `Pending Documents Review.png` | Embedded in `AccountScreen` | Landlord view: "Pending Reviews" with count, awaiting approval list with tenant avatar/unit, document thumbnail preview, document type/filename/upload time, "Request Changes"/"Approve" buttons | **MISMATCH** |

### J. MOVE-OUT (2 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| J1 | `Move-Out Request.png` | `MoveOutScreen` (bottom sheet) | Full screen: 60-day notice info banner, Planned Timeline (date picker), Forwarding Address (Street, City, Zip), Reason for Moving (chip tags: Buying/Relocation/Upsizing/Downsizing + comments textarea), consent checkbox, "Request Move-Out" button | **MISMATCH** |
| J2 | `Pending Move-Out Requests.png` | Embedded in `AccountScreen` | Landlord view: "Move-Outs" with pending count + earliest date banner, request cards with tenant avatar/name, property/unit, proposed date, urgency badge, reason text, Approve/Details/Reject buttons | **MISMATCH** |

### K. TENANT SCREENS (4 wireframes)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| K1 | `Tenant Dashboard (Pre-Active).png` | `TenantDashboard` | "My New Home", countdown to move-in (12 Days), unit address, Onboarding Checklist (65% complete: Verify Identity, Review & Sign Lease, Set Up Auto-Pay, Utilities Transfer), Lease/Documents quick cards, "Need help moving?" link, bottom nav: Home/Lease/Pay/Docs/Account | **MISMATCH** |
| K2 | `Tenant Dashboard (Active).png` | `TenantDashboard` | "Dashboard" with avatar, greeting, unit info, "NEXT PAYMENT DUE" banner with date + amount, "Pay Now" button, Quick Actions grid (View Lease, Upload Docs, History, Maintenance), Required Documents alert, Recent Activity feed | **MISMATCH** |
| K3 | `Tenant Onboarding.png` | Not implemented | "Onboarding" with progress bar (25%, 1 of 4), Required Steps checklist (Complete Profile - DONE, Upload Documents - Start, Add Payment Method - Start, Review Lease), Pro-tip info card, "Continue to Lease Review" button | **MISSING** |
| K4 | `Tenant Account_Settings.png` | `AccountScreen` | Avatar with "Gold Tenant" badge, email, "Edit Profile", sections: Financials (Payment Methods, Payment History), Property (Current Lease, Move-Out Request), Preferences (Push Notifications toggle, Security & Privacy), Support (Help Center, Contact Support), "Sign Out" button, version | **MISMATCH** |

### L. NOTIFICATIONS (1 wireframe)

| # | Wireframe PNG | Current Flutter Screen | Expected Functionality | Status |
|---|---|---|---|---|
| L1 | `Notifications.png` | Embedded in `AccountScreen` | Full dedicated screen: "Notifications" title, unread count + "Mark all read", grouped by TODAY/YESTERDAY, notification cards with colored icons (blue=Lease, green=Payment, blue=Tenant, orange=Message, green=Payment), type tag, time ago, description | **MISMATCH** |

---

## MISMATCH SUMMARY

### MISSING SCREENS (16 wireframes with no Flutter implementation)
1. **Forgot Password** (A4)
2. **Landlord Account Setup / Onboarding Checklist** (B3)
3. **Landlord Account Edit / Edit Preferences** (B5)
4. **Add Property Step 2: Structure Setup** (C5)
5. **Add Property Step 3: Review & Save** (C6)
6. **Property Created Success** (C9)
7. **Invite Sent Confirmation** (D2)
8. **Invite Expired/Invalid** (D3)
9. **Tenant Invite Acceptance** (D5)
10. **Tenant Invite Verification** (D6)
11. **Create Lease Step 4: Clauses & Notes** (E6)
12. **Create Lease Step 5: Review** (E7)
13. **Generated Lease Ready** (F1)
14. **Lease Signing (E-Sign pad)** (F2)
15. **Lease Signing Status / Timeline** (F3)
16. **Lease Signed Success** (F4)
17. **Lease Review (tenant pre-sign)** (F5)
18. **Payment Ledger** (H3)
19. **Rent Payment Success** (H5)
20. **Tenant Onboarding** (K3)

### SCREENS THAT EXIST BUT DON'T MATCH WIREFRAMES (all remaining ~34)
Every existing screen has layout, flow, and component mismatches vs wireframes. Key patterns:

1. **Splash/Welcome**: Missing "Login" + "Create Account" dual buttons, tagline, trust badge
2. **Login**: Missing social auth (Google/Apple), "Forgot password?" link, field icons, proper layout
3. **Register**: Not a multi-step flow, missing role cards with feature tags, missing trust badge
4. **Dashboards**: Missing Quick Actions grid, Recent Activity feed, stat cards don't match layout
5. **Properties**: Missing images, search bar, filter tabs, occupancy % badges, bottom actions
6. **Property Detail**: Missing hero image, stat circles, tab bar (Units/Tenants/Leases/Payments)
7. **Add Property**: Single bottom sheet instead of 3-step wizard with progress bar
8. **Unit editing**: Simple dialog instead of full screen with utility toggles, notes, ready checkbox
9. **Invitations**: Missing tenant name field, message customization, start date, tone selector
10. **Lease Settings**: Bottom sheet instead of full screen with clauses, policies, edit mode
11. **Create Lease**: Single sheet instead of 5-step wizard
12. **Lease List**: Missing property images, filter tabs (Drafts/Sent/Active), View/PDF actions
13. **Payments (landlord)**: Missing total collected/outstanding stats, filter tabs, transaction list
14. **Payments (tenant)**: Missing payment method cards, transaction summary, no inline pay
15. **Documents**: Missing progress indicator, status badges (Approved/Under Review/Missing)
16. **Move-out**: Missing notice banner, forwarding address, reason chips, consent checkbox
17. **Account**: Missing sections (Business & Finance, Preferences, Legal & Support)
18. **Notifications**: Embedded in account instead of dedicated screen with grouping

---

## REBUILD PLAN

### Phase 1: Auth & Onboarding (match wireframes A1-A4, B3)
- Rebuild Splash/Welcome as dedicated screen per A1
- Rebuild Login as full screen per A2 (social auth buttons, forgot password link)
- Rebuild Register as multi-step flow per A3 (role selection cards)
- Add Forgot Password screen per A4
- Add Landlord Onboarding Checklist screen per B3

### Phase 2: Landlord Dashboard & Account (B1-B5)
- Rebuild empty dashboard with CTA + Quick Setup Guide per B1
- Rebuild populated dashboard with Quick Actions grid + Recent Activity per B2
- Rebuild Account Settings as structured settings screen per B4
- Add Account Edit/Preferences screen per B5

### Phase 3: Property Management (C1-C9)
- Rebuild Property List empty state with HOW IT WORKS per C1
- Rebuild Property List with images, search, filters, occupancy per C2
- Rebuild Property Detail with hero image, stat circles, tab bar per C3
- Convert Add Property from bottom sheet to 3-step wizard (C4, C5, C6)
- Add Property Created Success screen per C9
- Rebuild Unit List with filters, actions, overdue warnings per C7
- Rebuild Unit Edit as full screen with utilities, notes per C8

### Phase 4: Invite Flow (D1-D6)
- Rebuild Invite Tenant as full screen with message customization per D1
- Add Invite Sent Confirmation per D2
- Add Invite Expired/Invalid screen per D3
- Rebuild Pending Invites as dedicated screen per D4
- Add Tenant Invite Acceptance screen per D5
- Add Tenant Invite Verification screen per D6

### Phase 5: Lease Management (E1-E10, F1-F5)
- Rebuild Lease Settings as full screen with clauses per E1, E2
- Convert Create Lease to 5-step wizard (E3-E7)
- Rebuild Lease List with images, filters, status badges per E8, E9
- Rebuild Lease Detail as full screen per E10
- Add Generated Lease Ready screen per F1
- Add E-Sign screen with signature pad per F2
- Add Signing Status/Timeline screen per F3
- Add Lease Signed Success screen per F4
- Add Lease Review (tenant) screen per F5

### Phase 6: Tenant Screens (K1-K4, G1)
- Rebuild Tenant Dashboard pre-active (countdown, checklist) per K1
- Rebuild Tenant Dashboard active (pay now, quick actions, activity) per K2
- Add Tenant Onboarding screen per K3
- Rebuild View Lease with PDF preview per G1
- Rebuild Tenant Account Settings per K4

### Phase 7: Payments & Documents (H1-H5, I1-I2)
- Rebuild Landlord Payments empty/populated per H1, H2
- Add Payment Ledger screen per H3
- Rebuild Rent Payment with method selection, summary per H4
- Add Payment Success screen per H5
- Rebuild Document Upload/Status with progress per I1
- Rebuild Pending Document Review (landlord) per I2

### Phase 8: Move-Out & Notifications (J1-J2, L1)
- Rebuild Move-Out Request with all fields per J1
- Rebuild Pending Move-Outs (landlord) per J2
- Add dedicated Notifications screen per L1
