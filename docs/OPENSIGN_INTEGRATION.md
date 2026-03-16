# AYRNOW — OpenSign Integration Notes

## Role Boundary
- **OpenSign owns**: signing workflow, signer links/routing, signature capture lifecycle, callback/webhook notifications
- **AYRNOW owns**: lease drafting, lease settings, lease lifecycle, tenant assignment, final internal lease state, signed document references

**Rule**: OpenSign is a signing engine, not AYRNOW's lease database.

## Current State
AYRNOW MVP handles lease signing via **internal API** (`POST /leases/:id/sign`). This updates the signature record and lease status directly. In production, OpenSign will manage the actual e-signature capture.

## Integration Plan

### 1. OpenSign Setup
- Self-host or use hosted OpenSign instance
- Get: base URL, API token
- Configure webhook callback URL pointing to AYRNOW backend

### 2. Backend Integration

#### Send Lease to OpenSign
```java
// In LeaseService.sendForSigning():
// 1. Generate lease PDF (openhtmltopdf already in pom.xml)
// 2. Upload PDF to OpenSign via API
// 3. Add signers (landlord + tenant emails)
// 4. Store OpenSign document ID in lease.opensignDocId
// 5. Update lease status to SENT_FOR_SIGNING
```

#### Receive Signing Webhook
```java
// New endpoint: POST /api/webhooks/opensign
// 1. Verify webhook signature
// 2. Parse signing event (signer completed, all signed, etc.)
// 3. Update LeaseSignature records
// 4. Update Lease status (LANDLORD_SIGNED, TENANT_SIGNED, FULLY_EXECUTED)
// 5. Store signed document URL
// 6. Send notifications
```

### 3. Frontend Integration
- Signing screen opens OpenSign signing URL in a WebView or external browser
- Status screen polls or receives push notification when signing completes
- Signed lease PDF becomes downloadable from lease detail

### 4. Environment Variables
```
OPENSIGN_BASE_URL=https://your-opensign-instance.com
OPENSIGN_API_TOKEN=your-api-token
OPENSIGN_WEBHOOK_SECRET=your-webhook-secret
```

### 5. API Reference
- Docs: https://docs.opensignlabs.com/
- API v1: https://docs.opensignlabs.com/docs/API-docs/v1/opensign-api-v-1/
- Self-host: https://docs.opensignlabs.com/docs/self-host/intro/

## What Already Exists
- `lease.opensignDocId` field in database schema
- `LeaseSignature` entity tracks per-signer status
- Lease status enum includes full signing lifecycle
- PDF generation dependency in `pom.xml` (openhtmltopdf)
