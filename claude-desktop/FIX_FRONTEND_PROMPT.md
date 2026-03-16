# AYRNOW Frontend Fix — Claude Code Prompt

Copy everything below the line and paste it into Claude Code terminal:

---

You are fixing the AYRNOW Flutter frontend end-to-end. The app has been audited across all 30 screen files + 6 non-screen files (36 Dart files total). There are 24 issues found: 6 critical bugs, 9 high-priority feature breaks, 4 missing screens/routes, and 5 medium stubs. Fix ALL issues listed below, verify with `flutter analyze`, and ensure 0 errors.

## True Status (from forensic audit):
- 54 wireframes total
- 34 screens COMPLETE
- 16 screens PARTIAL (exist but have bugs/gaps)
- 2 screens MISSING (#30 Clauses, #31 Review)
- 2 screens UNREACHABLE (Payment Ledger, Landlord Move-Outs)

## Context
- Repo: `/Users/imranshishir/Documents/claude/AYRNOW/ayrnowinc-V-1.0`
- Frontend: `frontend/` directory
- Backend API: Spring Boot at `http://localhost:8080/api`
- All files are in `frontend/lib/`

## CRITICAL FIXES (Priority 1 — App is broken without these)

### Fix 1: Auth flow — Login/Register don't navigate after success
**Files:** `screens/auth/login_screen.dart`, `screens/auth/register_screen.dart`

**Problem:** After successful login or register, the user stays on the same screen. The `AuthProvider` updates `isLoggedIn` to `true`, but since `_AuthFlow` in `main.dart` uses a local `_currentScreen` state variable (not watching AuthProvider), it never rebuilds to show the dashboard.

**Fix:** The `_AuthGate` in `main.dart` already uses `Consumer<AuthProvider>` which WILL rebuild when `isLoggedIn` changes. BUT the `_AuthFlow` widget wraps login/register screens — when auth succeeds, the Consumer in `_AuthGate` should switch to `LandlordShell` or `TenantShell` automatically.

Check if `AuthProvider.login()` and `register()` call `notifyListeners()` after setting `_isLoggedIn = true`. If they do, the Consumer should rebuild. If login/register still don't navigate, the issue is that the AuthProvider isn't setting state correctly. Debug by:
1. Adding print statements in AuthProvider.login() to verify `_isLoggedIn` is set
2. Verifying `notifyListeners()` is called after `_isLoggedIn = true`
3. If the issue is that `_error` is being set incorrectly, fix the error handling

Also: In `login_screen.dart`, the `_signIn()` method should show success feedback. In `register_screen.dart`, the `_register()` method should do the same.

### Fix 2: Token refresh logic missing
**File:** `services/api_service.dart`

**Problem:** No token refresh mechanism. When access token expires, all API calls fail silently.

**Fix:** Add automatic token refresh:
```dart
// In _headers() or as a wrapper around API calls:
// 1. Make request
// 2. If 401 response, try refresh token
// 3. Call POST /auth/refresh with refresh token
// 4. Save new access token
// 5. Retry original request
// 6. If refresh also fails, clear tokens and force re-login
```

Add a `_refreshToken()` method:
```dart
static Future<bool> _refreshToken() async {
  final refreshToken = await _storage.read(key: 'refreshToken');
  if (refreshToken == null) return false;
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['accessToken'], data['refreshToken']);
      return true;
    }
  } catch (_) {}
  return false;
}
```

Wrap all API methods to retry on 401:
```dart
static Future<Map<String, dynamic>> get(String path) async {
  var response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
  if (response.statusCode == 401) {
    final refreshed = await _refreshToken();
    if (refreshed) {
      response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    }
  }
  return _handleResponse(response);
}
```

Apply same pattern to `post()`, `put()`, `delete()`, `getList()`.

### Fix 3: Expired tokens not cleared on checkAuth failure
**File:** `providers/auth_provider.dart`

**Problem:** In `checkAuth()`, if the `/users/me` call fails (expired token), `_isLoggedIn` is set to `false` but tokens are NOT cleared from secure storage. Next app launch, it finds tokens, tries again, fails again — infinite loop.

**Fix:** In the catch block of `checkAuth()`, call `await ApiService.clearTokens()`:
```dart
} catch (e) {
  await ApiService.clearTokens(); // ADD THIS
  _isLoggedIn = false;
}
```

### Fix 4: Lease signing — signature data never sent to backend
**File:** `screens/shared/lease_signing_screen.dart`

**Problem:** The signature pad captures data but the POST to `/leases/{id}/sign` sends no payload.

**Fix:** Export signature as base64 PNG and include in the API call:
```dart
// In _submitSignature():
final signatureImage = await _signatureController.toPngBytes();
final base64Sig = base64Encode(signatureImage!);
await ApiService.post('/leases/${widget.leaseId}/sign', {
  'signature': base64Sig,
  'signedAt': DateTime.now().toIso8601String(),
});
```

### Fix 5: Invite accept — invite code not passed to register
**File:** `screens/tenant/invite_accept_screen.dart`

**Problem:** When tenant accepts invite and navigates to RegisterScreen, the invite code and email are lost.

**Fix:** Pass invite data to RegisterScreen. First update `RegisterScreen` to accept optional parameters:
```dart
class RegisterScreen extends StatefulWidget {
  final String? inviteCode;
  final String? prefilledEmail;
  const RegisterScreen({super.key, this.inviteCode, this.prefilledEmail});
```

Then in `invite_accept_screen.dart`, navigate with data:
```dart
Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (_) => RegisterScreen(
    inviteCode: widget.code,
    prefilledEmail: _invite?['tenantEmail'],
  ),
));
```

In RegisterScreen, pre-fill the email field and set role to TENANT if inviteCode is provided.

### Fix 6: Forgot password — completely stubbed
**File:** `screens/auth/forgot_password_screen.dart`

**Problem:** `_sendResetLink()` never calls the API. Just sets `_sent = true` locally.

**Fix:** Implement actual API call:
```dart
Future<void> _sendResetLink() async {
  if (_emailC.text.isEmpty) return;
  setState(() => _isLoading = true);
  try {
    await ApiService.post('/auth/forgot-password', {
      'email': _emailC.text.trim(),
    });
    setState(() => _sent = true);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset link: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```
Add `_isLoading` state variable and show loading indicator on button.

---

## HIGH PRIORITY FIXES (Priority 2 — Features broken)

### Fix 7: Silent error handling everywhere
**Files:** ALL screen files that have `catch (_) {}`

**Problem:** Every screen's `_loadData()` uses empty catch blocks. Users see no feedback when API calls fail.

**Fix:** In every screen, replace empty catches with user-visible error state:
```dart
} catch (e) {
  if (mounted) {
    setState(() => _error = e.toString());
    // OR show snackbar:
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load data'), backgroundColor: Colors.red),
    );
  }
}
```

Screens to fix:
- `tenant_dashboard.dart`
- `tenant_lease_screen.dart`
- `tenant_payment_screen.dart`
- `document_screen.dart`
- `property_list_screen.dart`
- `property_detail_screen.dart`
- `lease_list_screen.dart`
- `payment_list_screen.dart`
- `invite_screen.dart`
- `move_out_screen.dart`
- `notifications_screen.dart`
- `signing_status_screen.dart`
- `pending_document_review_screen.dart`

### Fix 8: Register Step 2 has no form validation
**File:** `screens/auth/register_screen.dart`

**Problem:** Step 2 (role selection + invite code) is not wrapped in a Form. TextFormField validators never run.

**Fix:** Either wrap step 2 in a separate Form, or validate manually before calling `_register()`:
```dart
if (_selectedRole == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Please select a role')),
  );
  return;
}
if (_selectedRole == 'TENANT' && _inviteCodeC.text.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Invite code is required for tenants')),
  );
  return;
}
```

### Fix 9: Password validation mismatch
**Files:** `login_screen.dart`, `register_screen.dart`

**Problem:** UI hints say "At least 8 characters" but validator only checks `length < 6`.

**Fix:** Change validators to `v.length < 8` in both files.

### Fix 10: Property detail — edit/delete not implemented
**File:** `screens/landlord/property_detail_screen.dart`

**Problem:** Edit and Delete options in the popup menu do nothing.

**Fix:** Implement edit navigation and delete with confirmation:
```dart
// Edit: Navigate to AddPropertyScreen in edit mode
case 'edit':
  final result = await Navigator.push(context,
    MaterialPageRoute(builder: (_) => AddPropertyScreen(property: widget.property)));
  if (result == true) _loadProperty();
  break;

// Delete: Confirm and call API
case 'delete':
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Delete Property'),
      content: Text('Are you sure? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (confirm == true) {
    await ApiService.delete('/properties/${widget.property['id']}');
    if (mounted) Navigator.pop(context, true);
  }
  break;
```

### Fix 11: Invite screen — resend button empty
**File:** `screens/shared/invite_screen.dart`

**Problem:** `onResend: () {}` — resend callback does nothing.

**Fix:**
```dart
onResend: () async {
  try {
    await ApiService.post('/invitations/${invite['id']}/resend', {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation resent')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend'), backgroundColor: Colors.red),
      );
    }
  }
},
```

### Fix 12: Move-out screen — forwarding address not sent to API
**File:** `screens/shared/move_out_screen.dart`

**Problem:** Address is captured in UI but not included in the POST body.

**Fix:** Add `forwardingAddress` to the API payload:
```dart
await ApiService.post('/move-out', {
  'leaseId': _selectedLeaseId,
  'requestedDate': _selectedDate!.toIso8601String(),
  'reason': _reasonC.text,
  'forwardingAddress': _addressC.text, // ADD THIS
});
```

### Fix 13: Unit utilities not persisted
**File:** `screens/landlord/edit_unit_screen.dart`

**Problem:** Utility toggles (electricity, water, internet, etc.) and "ready for leasing" checkbox are UI-only.

**Fix:** Include in the API payload:
```dart
final body = {
  'name': _nameC.text,
  'rent': double.parse(_rentC.text),
  'deposit': double.parse(_depositC.text),
  'notes': _notesC.text,
  'utilities': {
    'electricity': _electricity,
    'water': _water,
    'internet': _internet,
    'trash': _trash,
    'gas': _gas,
  },
  'readyForLeasing': _readyForLeasing,
};
```

### Fix 14: Notification filter chips don't filter
**File:** `screens/shared/notifications_screen.dart`

**Problem:** Filter chips exist in UI but don't actually filter the list.

**Fix:** Add filter state and apply it:
```dart
String _selectedFilter = 'All';

// Filter notifications in build:
final filtered = _selectedFilter == 'All'
  ? _notifications
  : _notifications.where((n) => n['type'] == _selectedFilter).toList();
```

### Fix 15: Payment list filters don't work
**File:** `screens/landlord/payment_list_screen.dart`

**Problem:** "Pending", "Paid", "Overdue" filter tabs are non-functional.

**Fix:** Add filter state and apply to the payment list within each property expansion tile.

---

## MISSING SCREENS (Priority 2B — Must create from scratch)

### Fix 16: Create Lease wizard missing steps 4-5
**File:** `screens/landlord/lease_list_screen.dart` (inside `_CreateLeaseWizard`)

**Problem:** Wireframe shows a 5-step lease wizard. Only 3 steps exist (Select Property → Tenant Info → Lease Terms). Steps 4 (Clauses & Notes) and 5 (Review & Confirm) are completely missing.

**Fix:** Add two more steps to the wizard:

**Step 4 — Clauses & Notes:**
- Clause template chips (Late Fee Policy, Pet Policy, Maintenance, Parking, Subletting)
- Active clauses list with toggle to enable/disable each
- Custom clause text editor
- Internal notes textarea (landlord-only)

**Step 5 — Review & Confirm:**
- Step dots showing all 5 steps
- Summary sections: Property, Tenant, Lease Terms, Clauses
- Each section has an "Edit" link back to that step
- "Generate & Send for Signature" button → calls POST /leases
- "Save as Draft" secondary button
- "PDF Preview" link (placeholder OK for MVP)

Update `_totalSteps` from 3 to 5 and wire step 4/5 navigation.

### Fix 17: Payment Ledger not reachable
**File:** `screens/landlord/payment_list_screen.dart`

**Problem:** `PaymentLedgerScreen` exists and is fully coded, but NO screen navigates to it.

**Fix:** In the landlord payments populated view, add a "View Ledger" button/link on each payment expansion tile that navigates to PaymentLedgerScreen:
```dart
TextButton(
  onPressed: () => Navigator.push(context,
    MaterialPageRoute(builder: (_) => PaymentLedgerScreen(leaseId: payment['leaseId']))),
  child: Text('View Ledger'),
),
```

### Fix 18: Landlord can't access Pending Move-Outs
**File:** `screens/landlord/account_screen.dart`

**Problem:** MoveOutScreen supports `isLandlord: true` mode, but the landlord Account screen has no menu item linking to it.

**Fix:** Add a "Move-Out Requests" item in the landlord Account screen's Property Management section:
```dart
_buildMenuItem(
  icon: Icons.exit_to_app,
  title: 'Move-Out Requests',
  subtitle: 'Review tenant move-out requests',
  onTap: () => Navigator.push(context,
    MaterialPageRoute(builder: (_) => MoveOutScreen(isLandlord: true))),
),
```

### Fix 19: iOS Info.plist missing camera/photo permissions
**File:** `frontend/ios/Runner/Info.plist`

**Problem:** Missing `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`. App will CRASH when user tries to upload documents or photos.

**Fix:** Add these keys inside the `<dict>` in Info.plist:
```xml
<key>NSCameraUsageDescription</key>
<string>AYRNOW needs camera access to capture documents and property photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>AYRNOW needs photo library access to upload documents and property photos</string>
```

---

## MEDIUM PRIORITY FIXES (Priority 3 — Stubs & hardcoded data)

### Fix 20: Onboarding screens hardcoded
**Files:** `landlord/onboarding_screen.dart`, `tenant/tenant_onboarding_screen.dart`

**Problem:** Progress percentages, task counts, and completion states are all hardcoded.

**Fix:** Fetch onboarding progress from `/dashboard/landlord` or `/dashboard/tenant` and compute:
- Count of properties (> 0 = property step done)
- Count of invites sent (> 0 = invite step done)
- Count of leases (> 0 = lease step done)
- Calculate percentage from completed/total steps

### Fix 21: Dashboard recent activity is static
**File:** `screens/landlord/landlord_dashboard.dart`

**Problem:** Activity feed shows hardcoded items, not real data.

**Fix:** Fetch recent activity from `/notifications` or a dedicated `/activity` endpoint and display real items.

### Fix 22: Payment stats hardcoded to $0
**Files:** `landlord/payment_list_screen.dart`, `landlord/property_detail_screen.dart`

**Problem:** Outstanding balance and next payout are hardcoded.

**Fix:** Calculate from actual payment data returned by the API.

### Fix 23: Notification preferences not persisted
**File:** `screens/landlord/edit_preferences_screen.dart`

**Problem:** Toggle switches for notification preferences are UI-only, never sent to API.

**Fix:** Include in the PUT `/users/me` call:
```dart
body['notificationPreferences'] = {
  'paymentReminders': _paymentReminders,
  'leaseUpdates': _leaseUpdates,
  'moveOutAlerts': _moveOutAlerts,
};
```

### Fix 24: BackendGuard lifecycleEnrichment type mismatch
**File:** `services/backend_guard.dart`

**Problem:** Compares `data['lifecycleEnrichment'] == 'true'` (string) but backend may return boolean.

**Fix:**
```dart
lifecycleEnrichment = data['lifecycleEnrichment'] == true || data['lifecycleEnrichment'] == 'true';
```

---

## VERIFICATION

After all fixes:
```bash
cd /Users/imranshishir/Documents/claude/AYRNOW/ayrnowinc-V-1.0/frontend
flutter analyze
flutter build ios --simulator  # or flutter run
```

Ensure:
- 0 compile errors
- 0 analysis errors
- Login → Dashboard navigation works
- Register → Dashboard navigation works
- Property CRUD works
- Lease creation works
- Payment flow initiates correctly
- Document upload works
- Move-out request works

## Rules
- Fix files in order of priority (1 → 2 → 3)
- Run `flutter analyze` after each batch of fixes
- If a fix introduces new errors, resolve before moving on
- Do NOT break existing working features
- Keep all fixes in the existing architecture (no rewrites)
- Commit after each priority batch with descriptive message
