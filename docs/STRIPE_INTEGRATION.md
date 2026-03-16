# AYRNOW — Stripe Integration Guide

## Architecture
```
[Flutter App] → POST /payments/{id}/checkout → [Spring Boot] → Stripe Checkout Session
                                                                      ↓
[Tenant Browser] ← checkout URL ← [Stripe Hosted Page]
                                                                      ↓
[Stripe] → POST /api/webhooks/stripe → [Spring Boot] → Update payment record → Notify
```

## Role Boundary
- **Stripe owns**: payment execution, card/bank processing, transaction state, hosted checkout UI
- **AYRNOW owns**: rent obligations, internal ledger, lease/property/unit linkage, payment history, receipt views
- **Webhook is the final truth**: payment status in AYRNOW DB is only updated via webhook, never from client-side

## Current Implementation

### Backend Components
| File | Purpose |
|------|---------|
| `PaymentService.java` | Checkout session creation, webhook handlers, payment CRUD |
| `PaymentController.java` | REST endpoints for payments + Stripe checkout |
| `WebhookController.java` | Stripe webhook receiver with signature verification |
| `Payment.java` | Entity with Stripe reference fields |
| `PaymentRepository.java` | Data access with Stripe ID lookups |
| `V2__Payment_stripe_fields.sql` | Migration adding currency, stripe_event_id, stripe_customer_id |

### Payment Flow
1. Lease becomes FULLY_EXECUTED → `PaymentService.createPaymentForLease()` auto-creates first rent payment (PENDING)
2. Tenant taps "Pay" → frontend calls `POST /payments/{id}/checkout`
3. Backend creates Stripe Checkout Session, stores `session_id`, returns checkout URL
4. Frontend opens Stripe hosted checkout page
5. Tenant completes payment on Stripe
6. Stripe sends `checkout.session.completed` webhook to `/api/webhooks/stripe`
7. Backend verifies signature, marks payment SUCCESSFUL, updates `paid_at` timestamp
8. Notifications sent to landlord and tenant
9. Dashboard stats and payment history updated

### Webhook Events Handled
| Event | Action |
|-------|--------|
| `checkout.session.completed` | Mark payment SUCCESSFUL, set `paid_at`, notify both parties |
| `checkout.session.expired` | Reset checkout session ID (allow retry), keep PENDING |
| `checkout.session.async_payment_failed` | Mark payment FAILED, notify tenant |

### Idempotency
- Each webhook event has a unique `event_id` stored in `payments.stripe_event_id`
- Duplicate events are detected and skipped
- Already-SUCCESSFUL payments are not re-processed
- Unique index on `stripe_event_id` prevents race conditions

## Setup for Local Testing

### 1. Get Stripe Test Keys
1. Go to [dashboard.stripe.com](https://dashboard.stripe.com)
2. Make sure "Test mode" is toggled ON (top-right)
3. Go to Developers → API Keys
4. Copy: `Publishable key` (pk_test_...) and `Secret key` (sk_test_...)

### 2. Set Environment Variables
Edit `backend/.env` (or `application.properties`):
```
STRIPE_SECRET_KEY=sk_test_YOUR_ACTUAL_TEST_KEY
STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET
STRIPE_SUCCESS_URL=http://localhost:8080/payment/success
STRIPE_CANCEL_URL=http://localhost:8080/payment/cancel
```

### 3. Install Stripe CLI for Webhook Testing
```bash
brew install stripe/stripe-cli/stripe
stripe login
```

### 4. Forward Webhooks to Local Backend
```bash
stripe listen --forward-to localhost:8080/api/webhooks/stripe
```
This prints a webhook signing secret (whsec_...). Use it as `STRIPE_WEBHOOK_SECRET`.

### 5. Test Payment Flow
```bash
# Login as landlord
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"stripe-landlord@test.com","password":"Test123!","firstName":"Stripe","lastName":"Landlord","role":"LANDLORD"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")

# Create property with unit
curl -X POST http://localhost:8080/api/properties \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Stripe Test Property","propertyType":"RESIDENTIAL","address":"1 Pay St","city":"NYC","state":"NY","postalCode":"10001","initialUnitCount":1}'

# Register tenant
TTOKEN=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"stripe-tenant@test.com","password":"Test123!","firstName":"Stripe","lastName":"Tenant","role":"TENANT"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")

# Create lease (use correct property/unit/tenant IDs)
# Lease → Send → Sign (both) → auto-creates payment

# Get tenant payments
curl http://localhost:8080/api/payments/tenant -H "Authorization: Bearer $TTOKEN"

# Start checkout (returns Stripe URL)
curl -X POST http://localhost:8080/api/payments/{PAYMENT_ID}/checkout \
  -H "Authorization: Bearer $TTOKEN"

# Open the checkout URL in a browser
# Use test card: 4242 4242 4242 4242, any future date, any CVC
```

### 6. Test Cards
| Card Number | Scenario |
|-------------|----------|
| `4242 4242 4242 4242` | Successful payment |
| `4000 0000 0000 0002` | Card declined |
| `4000 0000 0000 3220` | 3D Secure authentication |
| `4000 0025 0000 3155` | Requires authentication |

Use any future expiration date and any 3-digit CVC.

### 7. Verify Results
After Stripe webhook fires:
```bash
# Check payment status (should be SUCCESSFUL)
curl http://localhost:8080/api/payments/tenant -H "Authorization: Bearer $TTOKEN"

# Check landlord dashboard (revenue should update)
curl http://localhost:8080/api/dashboard/landlord -H "Authorization: Bearer $TOKEN"

# Check notifications
curl http://localhost:8080/api/notifications -H "Authorization: Bearer $TOKEN"
```

### 8. Database Verification
```sql
SELECT id, amount, status, stripe_checkout_session_id, stripe_event_id, paid_at
FROM payments ORDER BY id DESC;
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `STRIPE_SECRET_KEY` | Yes | Stripe API secret key (sk_test_... or sk_live_...) |
| `STRIPE_WEBHOOK_SECRET` | Yes | Webhook endpoint signing secret (whsec_...) |
| `STRIPE_SUCCESS_URL` | Yes | Redirect URL after successful payment |
| `STRIPE_CANCEL_URL` | Yes | Redirect URL if payment cancelled |

## Test Mode Verification Status (2026-03-15)
- [x] Stripe test secret key configured and verified
- [x] Stripe CLI installed and webhook listener tested
- [x] Checkout Session creation verified (3 real cs_test_ sessions)
- [x] Webhook endpoint received events via stripe trigger
- [x] Auto-payment creation on lease FULLY_EXECUTED verified
- [x] Payment DB records stripe_checkout_session_id correctly
- [x] Idempotent webhook handling implemented and tested
- [ ] Visual E2E via simulator checkout (ready — open checkout URL, pay with 4242424242424242)

## Production Checklist
- [ ] Switch from sk_test_ to sk_live_ key
- [ ] Create production webhook endpoint in Stripe Dashboard
- [ ] Set production STRIPE_WEBHOOK_SECRET
- [ ] Update success/cancel URLs to production domain
- [ ] Enable checkout.session.completed, checkout.session.expired events in Stripe Dashboard
- [ ] Test with real payment method
- [ ] Monitor webhook delivery in Stripe Dashboard → Webhooks
