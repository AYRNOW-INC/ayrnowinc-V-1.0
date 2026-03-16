# AYRNOW — AWS Deployment Plan

**No Docker** — all services deployed natively.

## Architecture

```
[Flutter App] → [ALB] → [EC2: Spring Boot JAR] → [RDS: PostgreSQL 16]
                                                → [S3: Document Storage]
                                                → [OpenSign Cloud/EC2]
                                                → [Stripe API]
```

## Services

### 1. Backend Hosting: EC2 or Elastic Beanstalk
- Deploy Spring Boot as executable JAR
- Instance: `t3.small` minimum (2 vCPU, 2GB RAM)
- Run: `java -jar ayrnow-backend-1.0.0-SNAPSHOT.jar`
- Use systemd service for auto-restart
- Alternative: AWS Elastic Beanstalk with Java platform (no Docker)

### 2. Database: Amazon RDS (PostgreSQL 16)
- Instance: `db.t3.micro` for MVP, `db.t3.small` for production
- Multi-AZ for production
- Automated backups enabled
- Flyway migrations run on app startup

### 3. File/Document Storage: Amazon S3
- Bucket for tenant documents and lease PDFs
- Update `FILE_UPLOAD_DIR` to use S3 client instead of local filesystem
- Add `aws-java-sdk-s3` dependency to pom.xml
- IAM role on EC2 for S3 access

### 4. SSL/Domain
- Route 53 for DNS
- ACM for SSL certificate
- ALB (Application Load Balancer) for HTTPS termination
- Domain: `api.ayrnow.com` for backend

### 5. Secrets Management
- AWS Secrets Manager or Parameter Store for:
  - Database credentials
  - JWT secret
  - Stripe keys
  - OpenSign API token

### 6. Logging/Monitoring
- CloudWatch for application logs
- CloudWatch Alarms for health check failures
- Spring Boot Actuator for metrics endpoint

### 7. CI/CD
- GitHub Actions for build + deploy
- Pipeline: push → build JAR → upload to S3 → deploy to EC2/EB
- Staging environment for pre-production testing

## Cost Estimate (MVP)

| Service | Monthly Cost |
|---------|-------------|
| EC2 t3.small | ~$15 |
| RDS db.t3.micro | ~$15 |
| S3 (minimal storage) | ~$1 |
| ALB | ~$16 |
| Route 53 | ~$1 |
| **Total** | **~$48/mo** |

## Deployment Steps

1. Create RDS PostgreSQL 16 instance
2. Create S3 bucket for documents
3. Create EC2 instance with Java 21
4. Configure security groups (EC2 ↔ RDS, ALB ↔ EC2)
5. Set environment variables via Parameter Store
6. Upload and run JAR
7. Configure ALB with health check on `/api/health`
8. Set up Route 53 DNS
9. Configure ACM SSL certificate
10. Update CORS and callback URLs for production domain

## Mobile App Deployment
- iOS: Build IPA, submit to App Store via App Store Connect
- Android: Build APK/AAB, submit to Google Play Console
- Both require: signing certificates, store listings, screenshots
