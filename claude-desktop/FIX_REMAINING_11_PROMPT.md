# AYRNOW Frontend — Fix Remaining 11 Issues (Verified Unfixed)

Copy everything below the line and paste it into Claude Code terminal:

---

A previous agent claimed to fix 20 issues but I verified the code and 11 issues are still broken. Do NOT claim something is "deferred" or "already working" — actually fix each one. I will verify your changes line by line after.

## Context
- Repo: `/Users/imranshishir/Documents/claude/AYRNOW/ayrnowinc-V-1.0`
- Frontend: `frontend/lib/`
- All backend endpoints exist and accept the fields listed below

## Rules
- ACTUALLY CHANGE THE CODE. Do not mark anything "deferred" or "already working" without proving it.
- Run `flutter analyze` after every batch. 0 errors required.
- Commit after each batch with accurate message describing what changed.
- If you're unsure about a backend field, include it anyway — extra fields in JSON are silently ignored by Spring Boot.

---

## BATCH 1: Code that captures data but never sends it (4 fixes)

### Fix A: Signature data never sent to backend
**File:** `frontend/lib/screens/shared/lease_signing_screen.dart`

**Current broken code (line ~35):**
```dart
await ApiService.post('/leases/${widget.lease['id']}/sign');
```

**Required fix:** Export signature as PNG bytes, encode to base64, and include in the POST body:
```dart
import 'dart:convert';

// In _sign() method:
final signatureBytes = await _signatureController.toPngBytes();
if (signatureBytes == null) {
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please draw your signature first')));
  return;
}
final base64Sig = base64Encode(signatureBytes);
await ApiService.post('/leases/${widget.lease['id']}/sign', body: {
  'signature': base64Sig,
  'signedAt': DateTime.now().toIso8601String(),
});
```

### Fix B: Forwarding address captured but not sent to API
**File:** `frontend/lib/screens/shared/move_out_screen.dart`

**Current broken code:**
```dart
await ApiService.post('/move-out', body: {
  'leaseId': _leaseId,
  'requestedDate': '...',
  'reason': ...,
});
```

**Required fix:** Add the forwarding address fields that the UI already captures:
```dart
await ApiService.post('/move-out', body: {
  'leaseId': _leaseId,
  'requestedDate': '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
  'reason': [if (_reasonTag != null) _reasonTag!, _reasonC.text].join(' - '),
  'forwardingAddress': _addressC.text.trim(),
});
```

### Fix C: Unit utilities and readyForLeasing not sent to API
**File:** `frontend/lib/screens/landlord/edit_unit_screen.dart`

**Current broken code (the `body` in `_save()`):**
```dart
final body = {
  'name': _nameC.text.trim(),
  'unitType': _type,
  'floor': _floorC.text.trim(),
  'monthlyRent': double.tryParse(_rentC.text),
  'description': _notesC.text.trim(),
};
```

**Required fix:** Add the utility fields and readyForLeasing that the UI already captures:
```dart
final body = {
  'name': _nameC.text.trim(),
  'unitType': _type,
  'floor': _floorC.text.trim(),
  'monthlyRent': double.tryParse(_rentC.text),
  'securityDeposit': double.tryParse(_depositC.text),
  'description': _notesC.text.trim(),
  'readyForLeasing': _readyForLeasing,
  'utilities': {
    'electricity': _electricity,
    'water': _water,
    'internet': _internet,
    'trash': _trash,
    'gas': _gas,
  },
};
```
Note: Check which utility variables actually exist in the file. Include all that are declared as state variables.

### Fix D: Invite date picker value never stored or sent
**File:** `frontend/lib/screens/shared/invite_screen.dart`

**Problem:** The invite form shows a date picker for proposed start date, but the selected date is never stored in state and never included in the POST /invitations body.

**Required fix:**
1. Find the date picker in the invite form
2. Add a `DateTime? _startDate` state variable if not present
3. Store the picked date in state
4. Include `'proposedStartDate': _startDate?.toIso8601String()` in the POST body

---

## BATCH 2: UI elements that pretend to work but don't (3 fixes)

### Fix E: Invite resend button shows "coming soon" instead of calling API
**File:** `frontend/lib/screens/shared/invite_screen.dart`

**Current broken code (line ~59-61):**
```dart
onResend: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Resend coming soon')));
},
```

**Required fix:**
```dart
onResend: () async {
  try {
    await ApiService.post('/invitations/${invite['id']}/resend', body: {});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation resent successfully')));
    }
    _load(); // Refresh list
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend: $e'), backgroundColor: Colors.red));
    }
  }
},
```

### Fix F: Payment filter chips change color but don't filter the list
**File:** `frontend/lib/screens/landlord/payment_list_screen.dart`

**Problem:** `_filter` state variable exists and chips update it, but the payment list is never filtered by it. The expansion tiles show ALL payments regardless of filter selection.

**Required fix:** Inside the ExpansionTile children where payments are listed for each property, filter them:
```dart
// When loading payments per property, apply filter:
final propertyPayments = allPaymentsForProperty.where((p) {
  if (_filter == 'All') return true;
  final status = (p['status'] ?? '').toString().toUpperCase();
  if (_filter == 'Pending') return status == 'PENDING';
  if (_filter == 'Paid') return status == 'SUCCESSFUL' || status == 'PAID';
  if (_filter == 'Overdue') return status == 'OVERDUE' || status == 'FAILED';
  return true;
}).toList();
```
Apply this filtering wherever payments are rendered in the populated view.

### Fix G: Property edit button — placeholder instead of real navigation
**File:** `frontend/lib/screens/landlord/property_detail_screen.dart`

**Problem:** The "edit" option in the property detail popup menu was claimed as fixed but verify it actually navigates to AddPropertyScreen in edit mode. If it just shows a snackbar or placeholder, fix it:

```dart
case 'edit':
  final result = await Navigator.push(context,
    MaterialPageRoute(builder: (_) => AddPropertyScreen(property: _property)));
  if (result == true && mounted) _loadProperty();
  break;
```
Note: AddPropertyScreen may need to accept an optional `property` parameter for edit mode. If it doesn't, add one:
- Accept `final Map<String, dynamic>? property;` in the constructor
- If property != null, pre-fill all form fields from it
- Change the save method to use PUT instead of POST when editing

---

## BATCH 3: Hardcoded data that should be dynamic (4 fixes)

### Fix H: Onboarding progress hardcoded
**Files:** `frontend/lib/screens/landlord/onboarding_screen.dart`, `frontend/lib/screens/tenant/tenant_onboarding_screen.dart`

**Problem:** Progress is always "25%" / "1 of 4" regardless of actual state.

**Required fix:** In `initState`, fetch dashboard data and compute progress:
```dart
Future<void> _loadProgress() async {
  try {
    final data = await ApiService.get('/dashboard/landlord'); // or /dashboard/tenant
    final properties = (data['totalProperties'] ?? 0) as int;
    final tenants = (data['totalTenants'] ?? 0) as int;
    final leases = (data['activeLeases'] ?? 0) as int;
    // For landlord: property, invite, lease, payment setup = 4 steps
    int done = 0;
    if (properties > 0) done++;
    if (tenants > 0) done++;
    if (leases > 0) done++;
    // Payment step = check if Stripe connected (or just count > 0 payments)
    if ((data['totalCollected'] ?? 0) > 0) done++;
    setState(() {
      _completedSteps = done;
      _totalSteps = 4;
      _progress = done / 4;
    });
  } catch (_) {}
}
```
Replace all hardcoded "25%", "1 of 4", etc. with the computed values.

### Fix I: Dashboard activity feed is hardcoded
**File:** `frontend/lib/screens/landlord/landlord_dashboard.dart`

**Problem:** Activity items are hardcoded strings, not from API.

**Required fix:** Fetch recent notifications and display them as activity:
```dart
List<dynamic> _recentActivity = [];

Future<void> _loadActivity() async {
  try {
    final notifications = await ApiService.getList('/notifications');
    setState(() => _recentActivity = notifications.take(5).toList());
  } catch (_) {}
}
```
In the activity section, replace hardcoded items with:
```dart
..._recentActivity.map((n) => ListTile(
  leading: Icon(_iconForType(n['type'])),
  title: Text(n['title'] ?? ''),
  subtitle: Text(n['message'] ?? ''),
  trailing: Text(_timeAgo(n['createdAt'])),
)),
```

### Fix J: Notification preferences not saved to API
**File:** `frontend/lib/screens/landlord/edit_preferences_screen.dart`

**Problem:** Toggle switches for payment reminders, lease updates, move-out alerts are UI-only.

**Required fix:** In the save method (wherever it calls PUT /users/me), include:
```dart
body['notificationPreferences'] = {
  'paymentReminders': _paymentReminders,
  'leaseUpdates': _leaseUpdates,
  'moveOutAlerts': _moveOutAlerts,
};
```
Also in `initState`, load current preferences from the user profile response.

### Fix K: Tenant dashboard quick action buttons are empty
**File:** `frontend/lib/screens/tenant/tenant_dashboard.dart`

**Problem:** Quick action buttons (View Lease, Upload Docs, Payment History, Maintenance) have empty `onPressed` callbacks.

**Required fix:** Wire each button to navigate to the correct tab or screen. Since TenantShell uses an indexed bottom nav, use a callback or find the shell state:
```dart
// Option 1: Direct navigation to the screen
onPressed: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const TenantLeaseScreen())),

// For each button:
// "View Lease" → TenantLeaseScreen
// "Upload Docs" → DocumentScreen
// "Payment History" → TenantPaymentScreen
// "Maintenance" → show SnackBar('Maintenance requests coming in a future update')
```

---

## VERIFICATION

After all fixes, run:
```bash
cd /Users/imranshishir/Documents/claude/AYRNOW/ayrnowinc-V-1.0/frontend
flutter analyze
```

Then list every file you changed with a 1-line description of what you actually changed (not what you intended to change). I will diff your commits to verify.
