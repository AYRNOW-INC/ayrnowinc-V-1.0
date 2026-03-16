# Frontend Auth Flow

Flutter auth implementation using Provider state management, secure token storage, and role-based routing.

---

## AuthProvider

Location: `lib/providers/auth_provider.dart`

Central auth state manager. Extends `ChangeNotifier`.

### State Fields
- `bool isLoading` — true during auth checks
- `bool isLoggedIn` — true when valid tokens exist
- `bool isLandlord` — true if role is LANDLORD
- `String? userId` — current user ID
- `String? role` — LANDLORD or TENANT
- `String? accessToken` — current JWT access token
- `String? refreshToken` — current JWT refresh token

### Methods

**checkAuth()** — Called on app startup
1. Read accessToken and refreshToken from `FlutterSecureStorage`
2. If no tokens: set `isLoggedIn = false`, notify
3. If tokens exist: call `GET /api/auth/me` with accessToken
4. If 200: set isLoggedIn, role, userId from response
5. If 401: attempt `POST /api/auth/refresh` with refreshToken
6. If refresh succeeds: store new tokens, retry me call
7. If refresh fails: clear storage, set `isLoggedIn = false`

**login(email, password)** — Called from LoginScreen
1. Call `POST /api/auth/login` with email/password
2. Store accessToken and refreshToken in `FlutterSecureStorage`
3. Set isLoggedIn, role, userId
4. Notify listeners (triggers navigation)

**register(email, password, firstName, lastName, phone, role, inviteCode)** — Called from RegisterScreen
1. Call `POST /api/auth/register` with all fields
2. Store tokens in `FlutterSecureStorage`
3. Set isLoggedIn, role, userId
4. Notify listeners

**logout()**
1. Clear tokens from `FlutterSecureStorage`
2. Reset all state fields
3. Notify listeners (triggers navigation to login)

## Token Storage

Uses `flutter_secure_storage` package.
- iOS: stored in Keychain
- Android: stored in EncryptedSharedPreferences
- Keys: `access_token`, `refresh_token`
- Tokens are never stored in plain SharedPreferences or local files

## ApiService

Location: `lib/services/api_service.dart`

Handles all HTTP calls to the backend.

- Base URL configured per environment (default: `http://localhost:8080`)
- Attaches `Authorization: Bearer <accessToken>` to all authenticated requests
- On 401 response: triggers token refresh via AuthProvider, retries original request once
- Returns parsed JSON or throws typed exceptions

## AuthGate (main.dart)

Location: `lib/main.dart`

Root-level widget that observes `AuthProvider` and routes accordingly:

```
AuthGate
  ├── isLoading == true  →  SplashScreen (loading spinner)
  ├── isLoggedIn == false →  LoginScreen
  ├── isLandlord == true  →  LandlordShell (landlord dashboard + tabs)
  └── isLandlord == false →  TenantShell (tenant dashboard + tabs)
```

AuthGate uses `Consumer<AuthProvider>` to rebuild on state changes. No manual route pushing needed for auth transitions.

## Route Structure

- `/` — AuthGate (decides destination)
- `/login` — LoginScreen
- `/register` — RegisterScreen
- `/home` — AppShell (redirects into landlord or tenant shell)

Login and Register are public routes. All other routes require `isLoggedIn == true`.

## LoginScreen

- Email and password text fields
- Login button calls `AuthProvider.login()`
- "Create Account" link navigates to RegisterScreen
- Google Sign-In button: shows "Coming Soon" snackbar
- Apple Sign-In button: shows "Coming Soon" snackbar
- Error display for invalid credentials

## RegisterScreen

- Fields: email, password, first name, last name, phone (optional)
- Role selector: Landlord / Tenant toggle
- Optional invite code field (shown for Tenant role)
- Register button calls `AuthProvider.register()`
- Error display for validation failures and duplicate email

## Social Auth Status

Google and Apple sign-in buttons are present in the UI for future use. Both display a "Coming Soon" message when tapped. No OAuth configuration or token exchange is implemented. This will be added in a future native OAuth phase without Authgear.
