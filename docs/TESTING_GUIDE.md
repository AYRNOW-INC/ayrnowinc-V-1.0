# AYRNOW — Testing Guide

## Quick Smoke Test

### 1. Start services
```bash
./scripts/run_all_local.sh
# Or manually: start PostgreSQL, backend, then frontend
```

### 2. API smoke test
```bash
# Health
curl http://localhost:8080/api/health

# Register landlord
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"landlord@test.com","password":"Test123!","firstName":"John","lastName":"Smith","role":"LANDLORD"}'

# Register tenant
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"tenant@test.com","password":"Test123!","firstName":"Jane","lastName":"Doe","role":"TENANT"}'

# Login (save token)
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"landlord@test.com","password":"Test123!"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")

# Create property
curl -X POST http://localhost:8080/api/properties \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Property","propertyType":"RESIDENTIAL","address":"123 Main St","city":"Austin","state":"TX","postalCode":"78701","initialUnitCount":2}'

# Dashboard
curl http://localhost:8080/api/dashboard/landlord -H "Authorization: Bearer $TOKEN"
```

## Frontend Testing

### Flutter analyze (static analysis)
```bash
cd frontend
flutter analyze
# Expected: 0 errors
```

### Widget tests
```bash
cd frontend
flutter test
```

### Manual testing checklist
1. App opens to Welcome screen with "Login" + "Create Account"
2. Register as Landlord (2-step: personal info → role selection)
3. Login with registered credentials
4. Dashboard shows empty state with "Add My First Property"
5. Navigate to Properties tab → empty state
6. Add property (3-step wizard) → Success screen
7. View property detail → unit list visible
8. Add/edit unit → save works
9. Navigate to Leases tab → empty state
10. Create lease (3-step wizard)
11. Log out, register as Tenant
12. Tenant dashboard shows pre-active or active state
13. Tenant lease tab shows lease details
14. Document upload works (file picker → API call)
15. Move-out request form submits correctly
16. Notifications screen shows entries
17. Account screen shows correct role-based sections

## Backend Testing

### Unit tests (not yet implemented)
```bash
cd backend
/opt/homebrew/bin/mvn test
```

### Database verification
```bash
psql ayrnow -U ayrnow -c "\dt"
# Should list 16 tables
```

### API authorization test
```bash
# Should return 403 (no token)
curl -o /dev/null -w "%{http_code}" http://localhost:8080/api/properties

# Should return 200 (with token)
curl -o /dev/null -w "%{http_code}" http://localhost:8080/api/properties -H "Authorization: Bearer $TOKEN"
```

## Known Test Limitations
- Backend unit tests not yet written (test directory exists but is empty)
- Stripe checkout requires real/test Stripe keys to fully test payment flow
- Social login buttons show 'Coming Soon' (native OAuth deferred)
- OpenSign signing integration is stubbed
- Document download requires file to exist at stored path
