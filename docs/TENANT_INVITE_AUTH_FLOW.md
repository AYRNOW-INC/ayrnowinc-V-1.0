# Tenant Invite Auth Flow

How tenant invitations integrate with the registration and authentication system.

---

## Overview

Landlords invite tenants to specific units/spaces using an invite code. When a tenant registers with that code, the backend automatically links them to the correct invitation, unit, and property. No manual tenant-to-unit assignment is needed after invite acceptance.

## Invitation Creation (Landlord Side)

1. Landlord navigates to a unit/space in their property
2. Landlord taps "Invite Tenant"
3. Enters tenant email (and optionally phone)
4. Backend creates an `Invitation` record:
   - `invite_code`: system-generated short alphanumeric code
   - `unit_space_id`: the target unit/space
   - `property_id`: the parent property
   - `landlord_id`: the inviting landlord's userId
   - `tenant_email`: the invited email address
   - `status`: PENDING
5. Backend may send an email/notification with the invite code (or landlord shares it directly)

## Tenant Registration with Invite Code

1. Tenant receives invite code (via email, text, or verbal)
2. Tenant opens the app, navigates to Register
3. Selects role: TENANT
4. Fills in: email, password, first name, last name, optional phone
5. Enters invite code in the invite code field
6. Taps Register

### Backend Processing (AuthService.register)

1. Validate registration fields
2. Create user, role, and tenant profile (standard registration)
3. Detect `inviteCode` is present
4. Call `InvitationService.acceptInvite(inviteCode, userId)`:
   - Find invitation by `invite_code`
   - Verify invitation status is PENDING or SENT
   - Verify invitation is not expired
   - Update invitation status to ACCEPTED
   - Set `tenant_id` on the invitation record
   - Update `unit_space` occupancy — link tenant to the unit
   - Create tenant profile association with the property/unit
5. Issue JWT tokens (access + refresh)
6. Return `AuthResponse` — tenant is now logged in and linked

## Invite-Aware Onboarding

After registration with an invite code, the tenant's dashboard immediately shows:
- Assigned property name and address
- Assigned unit/space details
- Pending lease (if landlord has already created one)
- Document upload requirements

Without an invite code, a tenant registers but has no assigned property. They wait for a landlord to invite them.

## InviteAcceptScreen (Flutter)

Location: `lib/screens/invite_accept_screen.dart`

This screen handles the case where a tenant receives a deep link or manually enters an invite code after already being registered:

1. Tenant enters invite code
2. App calls `POST /api/invitations/accept` with the code
3. Backend links tenant to unit (same logic as registration)
4. Screen shows success and navigates to tenant dashboard

## Invitation Statuses

| Status | Meaning |
|---|---|
| PENDING | Created by landlord, not yet sent or acted on |
| SENT | Notification/email sent to tenant |
| OPENED | Tenant viewed the invite (if tracked) |
| ACCEPTED | Tenant registered or accepted with this code |
| EXPIRED | Time limit passed without acceptance |
| CANCELLED | Landlord cancelled the invitation |

## Validation Rules

- An invite code can only be used once
- An accepted invitation cannot be re-accepted
- An expired invitation returns an error on registration
- A cancelled invitation returns an error on registration
- The invite code is case-insensitive
- If the registering email does not match `tenant_email` on the invitation, the backend may warn but still allows acceptance (landlord may have shared the code verbally)

## Data Flow Diagram

```
Landlord                        Backend                         Tenant
   |                               |                               |
   |-- Create Invite (unit X) ---->|                               |
   |                               |-- Store invitation (PENDING)  |
   |                               |                               |
   |                               |<--- Register + inviteCode ----|
   |                               |                               |
   |                               |-- Create user                 |
   |                               |-- Create role (TENANT)        |
   |                               |-- Create tenant_profile       |
   |                               |-- Accept invitation           |
   |                               |-- Link tenant to unit X       |
   |                               |-- Issue JWT                   |
   |                               |                               |
   |                               |--- AuthResponse (tokens) ---->|
   |                               |                               |
   |                               |    Tenant sees assigned unit  |
```

## Edge Cases

- **Tenant registers without invite code:** Account is created but no property/unit is assigned. Tenant sees empty dashboard until invited.
- **Invite code entered after registration:** Use InviteAcceptScreen or API endpoint to link post-registration.
- **Multiple invites to same email:** Each invite is independent. Tenant accepts each one separately.
- **Landlord cancels after send:** Tenant gets an error if they try to use the cancelled code.
