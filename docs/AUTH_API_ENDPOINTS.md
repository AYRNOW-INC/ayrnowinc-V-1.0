# Auth API Endpoints

Complete reference for AYRNOW authentication and user endpoints.

---

## POST /api/auth/register

Create a new user account.

**Request Body:**
```json
{
  "email": "string (required, valid email)",
  "password": "string (required, min 8 chars)",
  "firstName": "string (required)",
  "lastName": "string (required)",
  "phone": "string (optional)",
  "role": "string (required, LANDLORD or TENANT)",
  "inviteCode": "string (optional, for tenant invite linking)"
}
```

**Success Response:** `201 Created`
```json
{
  "accessToken": "string (JWT, 30 min TTL)",
  "refreshToken": "string (JWT, 7 day TTL)",
  "role": "LANDLORD",
  "userId": 1
}
```

**Error Responses:**
- `409 Conflict` — `{"error": "Email already in use"}`
- `400 Bad Request` — `{"error": "Validation failed", "details": {...}}`
- `404 Not Found` — `{"error": "Invalid invite code"}` (if inviteCode provided but not found)

---

## POST /api/auth/login

Authenticate an existing user.

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Success Response:** `200 OK`
```json
{
  "accessToken": "string (JWT, 30 min TTL)",
  "refreshToken": "string (JWT, 7 day TTL)",
  "role": "TENANT",
  "userId": 2
}
```

**Error Responses:**
- `401 Unauthorized` — `{"error": "Invalid email or password"}`

---

## POST /api/auth/refresh

Exchange a valid refresh token for a new token pair.

**Request Body:**
```json
{
  "refreshToken": "string (required)"
}
```

**Success Response:** `200 OK`
```json
{
  "accessToken": "string (new JWT, 30 min TTL)",
  "refreshToken": "string (new JWT, 7 day TTL)",
  "role": "LANDLORD",
  "userId": 1
}
```

**Error Responses:**
- `401 Unauthorized` — `{"error": "Token expired or invalid"}`

---

## GET /api/auth/me

Get the current authenticated user's info.

**Headers:** `Authorization: Bearer <accessToken>`

**Success Response:** `200 OK`
```json
{
  "id": 1,
  "email": "user@example.com",
  "firstName": "Jane",
  "lastName": "Doe",
  "phone": "+15551234567",
  "role": "LANDLORD",
  "status": "ACTIVE",
  "emailVerified": false
}
```

**Error Responses:**
- `401 Unauthorized` — Missing or invalid token

---

## GET /api/users/me

Get the current user's profile (alias for authenticated user details).

**Headers:** `Authorization: Bearer <accessToken>`

**Success Response:** `200 OK`
```json
{
  "id": 1,
  "email": "user@example.com",
  "firstName": "Jane",
  "lastName": "Doe",
  "phone": "+15551234567",
  "role": "LANDLORD",
  "status": "ACTIVE"
}
```

**Error Responses:**
- `401 Unauthorized` — Missing or invalid token

---

## PUT /api/users/me

Update the current user's profile fields.

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:** (all fields optional, only provided fields are updated)
```json
{
  "firstName": "string",
  "lastName": "string",
  "phone": "string"
}
```

**Success Response:** `200 OK`
```json
{
  "id": 1,
  "email": "user@example.com",
  "firstName": "Janet",
  "lastName": "Doe",
  "phone": "+15559876543",
  "role": "LANDLORD",
  "status": "ACTIVE"
}
```

**Error Responses:**
- `401 Unauthorized` — Missing or invalid token
- `400 Bad Request` — `{"error": "Validation failed", "details": {...}}`

**Note:** Email and password cannot be changed through this endpoint. Email change and password change will be separate flows.

---

## Common Headers

All authenticated endpoints require:
```
Authorization: Bearer <accessToken>
Content-Type: application/json
```

## Token Format

JWTs contain these claims:
- `sub` — userId (string)
- `role` — LANDLORD or TENANT
- `iat` — issued at (epoch seconds)
- `exp` — expiration (epoch seconds)

Signed with HMAC-SHA256 using the server's `JWT_SECRET`.
