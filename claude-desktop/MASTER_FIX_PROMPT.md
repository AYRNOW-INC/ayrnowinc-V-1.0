# AYRNOW — Master Fix Prompt (Finish Everything End-to-End)

Copy everything below the line and paste into Claude Code:

---

## YOUR MISSION

Fix the AYRNOW Flutter frontend so that ALL 54 wireframe screens are fully functional — no stubs, no "coming soon", no empty callbacks, no hardcoded data, no missing API calls. You will work through every issue, verify each fix compiles, and NOT stop until a final verification pass confirms zero remaining issues.

## HARD RULES

1. **DO NOT say "deferred" or "already working" unless you prove it with code evidence.**
2. **DO NOT show "coming soon" snackbars.** Either implement the feature or remove the button.
3. **Every onPressed callback must do something real** — navigate, call API, or show a meaningful dialog.
4. **Every piece of data the UI captures must be sent to the API.** Extra JSON fields are silently ignored by Spring Boot.
5. **Run `flutter analyze` after EVERY batch of fixes.** 0 errors required before committing.
6. **Commit after each batch** with an accurate message listing exactly what changed.
7. **After all fixes, do a FULL verification pass:** read every file and confirm zero remaining issues.
8. **If verification finds more issues, fix them and verify again. Loop until clean.**

## CONTEXT

- Repo: `/Users/imranshishir/Documents/claude/AYRNOW/ayrnowinc-V-1.0`
- Frontend: `frontend/lib/`
- Backend API base: `http://localhost:8080/api` (Spring Boot, 48+ endpoints, all working)
- 30 screen files + 6 service/config files = 36 Dart files total
- 54 wireframes to cover

---

## PHASE 1: REMAINING BROKEN CODE (verified still broken)

### 1A. Unit save missing utilities and readyForLeasing
**File:** `screens/landlord/edit_unit_screen.dart`
**Evidence:** `_save()` body only has name, unitType, floor, monthlyRent, description. The UI captures `_electricity`, `_water`, `_internet`, `_trash`, `_gas`, `_readyForLeasing` but none are in the body.
**Fix:** Add all captured fields to the API body:
```dart
final body = {
  'name': _nameC.text.trim(),
  'unitType': _type,
  'floor': _floorC.text.trim(),
  'monthlyRent': double.tryParse(_rentC.text),
  'securityDeposit': double.tryParse(_depositC.text),
  'description': _notesC.text.trim(),
  'readyForLeasing': _readyForLeasing,
  'includedUtilities': [
    if (_electricity) 'electricity',
    if (_water) 'water',
    if (_internet) 'internet',
    if (_trash) 'trash',
    if (_gas) 'gas',
  ],
};
```

### 1B. Payment filter chips don't filter the list
**File:** `screens/landlord/payment_list_screen.dart`
**Evidence:** `_filter` variable exists, chips update it via `setState`, but the payment list in ExpansionTile children is NEVER filtered by `_filter`. All payments always show.
**Fix:** Where payments are listed inside each property's ExpansionTile, filter them:
```dart
final payments = (propertyPayments as List).where((p) {
  if (_filter == 'All') return true;
  final status = (p['status'] ?? '').toString().toUpperCase();
  return switch (_filter) {
    'Pending' => status == 'PENDING',
    'Paid' => status == 'SUCCESSFUL' || status == 'PAID',
    'Overdue' => status == 'OVERDUE' || status == 'FAILED',
    _ => true,
  };
}).toList();
```
Then use `payments` (not the original unfiltered list) to build the payment tiles.

### 1C. Invite resend is still a stub
**File:** `screens/shared/invite_screen.dart`
**Evidence:** Line ~59: `onResend` shows `SnackBar(content: Text('Resend coming soon'))`.
**Fix:** Replace with actual API call:
```dart
onResend: () async {
  try {
    await ApiService.post('/invitations/${invite['id']}/resend', body: {});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation resent!')));
      _load();
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend: $e'), backgroundColor: Colors.red));
    }
  }
},
```

### 1D. Property edit shows "coming soon"
**File:** `screens/landlord/property_detail_screen.dart`
**Evidence:** Line ~70-72: `if (v == 'edit')` shows snackbar "Edit property coming soon".
**Fix:** Navigate to AddPropertyScreen with the property data for editing. If AddPropertyScreen doesn't accept an edit mode, add one:
1. In `add_property_screen.dart`, add optional `property` parameter to constructor
2. If property != null, pre-fill all fields and use PUT instead of POST on save
3. In property_detail, navigate: `Navigator.push(context, MaterialPageRoute(builder: (_) => AddPropertyScreen(property: _property)))`
4. On return, refresh the property detail

### 1E. Onboarding hardcoded name "Michael"
**File:** `screens/landlord/onboarding_screen.dart`
**Evidence:** `'Welcome, Michael!'` is hardcoded text.
**Fix:** Get user name from AuthProvider:
```dart
final auth = Provider.of<AuthProvider>(context, listen: false);
final name = auth.user?['firstName'] ?? auth.user?['name'] ?? 'there';
```
Use `'Welcome, $name!'` instead.

### 1F. Tenant onboarding hardcoded progress
**File:** `screens/tenant/tenant_onboarding_screen.dart`
**Evidence:** `'25%\nCOMPLETE'` and `'1 of 4 tasks completed'` are hardcoded strings.
**Fix:** Compute from dashboard data:
```dart
Future<void> _loadProgress() async {
  try {
    final data = await ApiService.get('/dashboard/tenant');
    int done = 0;
    if (data['hasProfile'] == true || (data['profileComplete'] ?? false)) done++;
    if ((data['documentsUploaded'] ?? 0) > 0) done++;
    if ((data['activeLeases'] ?? 0) > 0) done++;
    if ((data['totalPayments'] ?? 0) > 0) done++;
    if (mounted) setState(() { _done = done; _total = 4; });
  } catch (_) {}
}
```
Replace hardcoded text with `'${(_done/_total * 100).round()}%\nCOMPLETE'` and `'$_done of $_total tasks completed'`.

### 1G. Tenant dashboard hardcoded 65%
**File:** `screens/tenant/tenant_dashboard.dart`
**Evidence:** `'65% Complete'` is hardcoded in the pre-active dashboard.
**Fix:** Same approach — compute from dashboard API data and display dynamic percentage.

### 1H. Notification preferences not saved
**File:** `screens/landlord/edit_preferences_screen.dart`
**Evidence:** Toggle switches for notifications exist in UI. Check if the save/update method includes them in the API body. If not, add them.
**Fix:** In the save method, include notification preferences:
```dart
body['notificationPreferences'] = {
  'paymentReminders': _paymentReminders,
  'leaseUpdates': _leaseUpdates,
  'moveOutAlerts': _moveOutAlerts,
};
```

### 1I. Login forgot password — verify it navigates
**File:** `screens/auth/login_screen.dart`
**Evidence:** Has `onForgotPassword` callback. Check if main.dart wires it to `ForgotPasswordScreen`.
**Fix if broken:** In main.dart `_AuthFlow`, ensure the login screen's `onForgotPassword` navigates to `ForgotPasswordScreen`.

### 1J. Google/Apple sign-in stubs on login
**File:** `screens/auth/login_screen.dart`
**Evidence:** Shows "Google sign-in coming soon" / "Apple sign-in coming soon" snackbars.
**Fix:** Since Authgear isn't integrated yet, change these to show a proper dialog:
```dart
showDialog(context: context, builder: (_) => AlertDialog(
  title: const Text('Social Sign-In'),
  content: const Text('Google and Apple sign-in will be available once Authgear is configured. For now, please use email and password.'),
  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
));
```
This is honest — not "coming soon" but explains the situation.

---

## PHASE 2: WIREFRAME FIDELITY (from forensic audit)

These are screens that exist but are missing elements the wireframes show:

### 2A. Property list missing EDIT/LEASE button actions
**File:** `screens/landlord/property_list_screen.dart`
**Evidence (from TEAM_AUDIT):** Property cards have EDIT and LEASE buttons that are placeholder callbacks.
**Fix:** EDIT → navigate to property detail or edit mode. LEASE → navigate to lease settings or create lease for that property.

### 2B. Lease detail is bottom sheet, wireframe shows full screen
**File:** `screens/landlord/lease_list_screen.dart`
**Evidence:** `_showDetail()` uses a `showModalBottomSheet`. Wireframe #34 shows a full-screen lease detail.
**Fix:** Replace bottom sheet with `Navigator.push` to a dedicated lease detail view (can be a new private widget or inline class within the file).

### 2C. Signing status "Send Reminder" buttons are placeholders
**File:** `screens/shared/signing_status_screen.dart`
**Evidence:** "Send Reminder" buttons show snackbar instead of calling API.
**Fix:** Call POST `/notifications` or a reminder endpoint:
```dart
onPressed: () async {
  try {
    await ApiService.post('/leases/${widget.leaseId}/remind', body: {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder sent!')));
  } catch (e) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
  }
},
```

### 2D. Tenant lease "Download PDF" and "Contact landlord" are stubs
**File:** `screens/tenant/tenant_lease_screen.dart`
**Evidence:** Both show placeholder snackbars.
**Fix:**
- Download PDF: If lease has a `documentUrl`, launch it with `url_launcher`. If not, show "PDF will be available after lease is signed via OpenSign."
- Contact landlord: Show a dialog with the landlord's email/phone from the lease data, with a "Send Email" button using `url_launcher`.

### 2E. Payment success "Save PDF" and "Share" are stubs
**File:** `screens/tenant/payment_success_screen.dart`
**Evidence:** Both show "Feature coming soon".
**Fix:** Remove the buttons entirely if they can't work, OR implement basic share using `url_launcher` with a `mailto:` link containing payment details.

### 2F. Tenant dashboard "Pay Now" wiring
**File:** `screens/tenant/tenant_dashboard.dart`
**Evidence (from FORENSIC_54):** "Pay Now" button in active dashboard may not navigate to payment tab.
**Fix:** Navigate to TenantPaymentScreen:
```dart
onPressed: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const TenantPaymentScreen())),
```

### 2G. Dashboard "View All" activity callback
**File:** `screens/landlord/landlord_dashboard.dart`
**Evidence:** "View All" button for activity feed is empty or placeholder.
**Fix:** Navigate to NotificationsScreen:
```dart
onPressed: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const NotificationsScreen())),
```

### 2H. Lease settings missing clause management
**File:** `screens/landlord/property_detail_screen.dart` (inside `_LeaseSettingsScreen`)
**Evidence (from FORENSIC_54):** Missing clause list with Active/Optional badges, and "+ Manage Custom Clauses" link.
**Fix:** If the lease settings screen has a clauses section, add a list of common clause templates with toggle switches. If it doesn't, add a section:
```dart
// Standard Clauses section
const Text('Standard Clauses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
...['Late Fee Policy', 'Pet Policy', 'Maintenance Responsibility', 'Parking', 'Subletting'].map((c) =>
  SwitchListTile(title: Text(c), value: _clauses[c] ?? true, onChanged: (v) => setState(() => _clauses[c] = v))),
```

---

## PHASE 3: FINAL SWEEP

After Phases 1-2, do a complete sweep of every file:

### 3A. Search for ALL remaining stubs
```bash
grep -rn "coming soon\|placeholder\|TODO\|FIXME\|not implemented" frontend/lib/screens/ --include="*.dart"
```
Fix every result.

### 3B. Search for ALL empty callbacks
```bash
grep -rn "onPressed: () {}\|onTap: () {}\|() => {}" frontend/lib/screens/ --include="*.dart"
```
Fix every result — wire to real navigation or API call.

### 3C. Search for ALL hardcoded user data
```bash
grep -rn "Michael\|John\|Jane\|hardcoded\|65%\|25%" frontend/lib/screens/ --include="*.dart"
```
Replace with dynamic data from API.

### 3D. Run flutter analyze
```bash
cd frontend && flutter analyze
```
Must be 0 errors, 0 warnings that indicate real issues.

---

## PHASE 4: VERIFICATION LOOP

After all fixes, verify by reading EVERY screen file and checking:
1. Every `onPressed` does something real
2. Every API call includes all UI-captured data in its body
3. No "coming soon" or "placeholder" strings remain
4. No hardcoded user names, percentages, or counts
5. All navigation paths work (no dead ends)
6. Error states show user-visible messages (no empty catches)

**If you find ANY remaining issue during verification, fix it immediately and re-verify.**

**You are done ONLY when:**
- `flutter analyze` returns 0 errors
- `grep -rn "coming soon" frontend/lib/screens/` returns nothing
- `grep -rn "onPressed: () {}" frontend/lib/screens/` returns nothing
- You've read every file and confirmed it's clean

Commit the final state with message: `fix: complete end-to-end frontend — all 54 screens functional`

---

## REFERENCE: Backend Endpoints Available

All these endpoints exist and work. Use them:

```
POST   /auth/register
POST   /auth/login
POST   /auth/refresh
POST   /auth/forgot-password
GET    /users/me
PUT    /users/me

GET    /properties
POST   /properties
GET    /properties/{id}
PUT    /properties/{id}
DELETE /properties/{id}
GET    /properties/{id}/units
POST   /properties/{id}/units
PUT    /properties/{id}/units/{unitId}
DELETE /properties/{id}/units/{unitId}
GET    /properties/{id}/lease-settings
PUT    /properties/{id}/lease-settings

GET    /invitations
POST   /invitations
DELETE /invitations/{id}
POST   /invitations/{id}/resend
GET    /invitations/accept/{code}

GET    /leases/landlord
GET    /leases/tenant
POST   /leases
GET    /leases/{id}
POST   /leases/{id}/sign
POST   /leases/{id}/remind

GET    /documents/tenant
GET    /documents/lease/{leaseId}
POST   /documents (multipart)
PUT    /documents/{id}/review

GET    /payments/tenant
GET    /payments/property/{propertyId}
GET    /payments/lease/{leaseId}
POST   /payments/{id}/checkout

GET    /move-out/tenant
GET    /move-out/landlord
POST   /move-out
PUT    /move-out/{id}/review

GET    /notifications
PUT    /notifications/{id}/read
PUT    /notifications/read-all

GET    /dashboard/landlord
GET    /dashboard/tenant

GET    /webhooks/stripe (POST for Stripe callbacks)
```
