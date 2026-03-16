# AYRNOW — Dependency Checklist

## Required Stack Verification

| Component | Required | Actual | Status |
|-----------|----------|--------|--------|
| Flutter | Frontend framework | 3.41.4 | COMPLIANT |
| Spring Boot | Backend framework | 3.4.4 | COMPLIANT |
| PostgreSQL | Database | 16.13 | COMPLIANT |
| Flyway | Schema migrations | Managed by Spring Boot | COMPLIANT |
| Monolith | Architecture | Single Spring Boot JAR | COMPLIANT |
| Docker | Must NOT be used | Not present anywhere | COMPLIANT |

## Backend Dependencies (pom.xml)

| Dependency | Version | Purpose | Status |
|------------|---------|---------|--------|
| spring-boot-starter-web | 3.4.4 | REST API | ACTIVE |
| spring-boot-starter-data-jpa | 3.4.4 | Database ORM | ACTIVE |
| spring-boot-starter-security | 3.4.4 | Auth/authz | ACTIVE |
| spring-boot-starter-validation | 3.4.4 | Input validation | ACTIVE |
| postgresql | managed | DB driver | ACTIVE |
| flyway-core + flyway-database-postgresql | managed | Migrations | ACTIVE |
| jjwt-api/impl/jackson | 0.12.6 | JWT tokens | ACTIVE |
| stripe-java | 28.2.0 | Payment processing | ACTIVE |
| openhtmltopdf-pdfbox | 1.0.10 | PDF generation | INCLUDED (not yet used) |
| lombok | managed | Boilerplate reduction | ACTIVE |
| jackson-datatype-jsr310 | managed | Date/time JSON | ACTIVE |

## Frontend Dependencies (pubspec.yaml)

| Dependency | Version | Purpose | Status |
|------------|---------|---------|--------|
| flutter | SDK | UI framework | ACTIVE |
| provider | ^6.1.2 | State management | ACTIVE |
| http | ^1.2.2 | API client | ACTIVE |
| go_router | ^14.8.1 | Routing | INCLUDED (not yet used — using Navigator) |
| shared_preferences | ^2.3.4 | Local storage | INCLUDED |
| flutter_secure_storage | ^9.2.4 | Token storage | ACTIVE |
| intl | ^0.19.0 | Date formatting | INCLUDED |
| image_picker | ^1.1.2 | Camera/gallery | INCLUDED |
| file_picker | ^8.1.6 | Document upload | ACTIVE |
| url_launcher | ^6.3.1 | External URLs (Stripe) | ACTIVE |

## External Integrations

| Service | Required | Integration Status |
|---------|----------|-------------------|
| Native Auth | Auth provider | IMPLEMENTED — native JWT auth with login, register, token refresh |
| OpenSign | E-signing | STUBBED — internal sign endpoint used |
| Stripe | Payments | ACTIVE — checkout + webhook built |
