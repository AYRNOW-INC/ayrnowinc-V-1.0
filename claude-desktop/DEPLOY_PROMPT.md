# AYRNOW AWS Deployment — Claude Code Prompt

Copy everything below the line and paste it into Claude Code terminal:

---

You are deploying the AYRNOW Spring Boot backend to AWS Elastic Beanstalk with RDS PostgreSQL. The deployment config files are already in the repo. Your job is to execute the full deployment end-to-end.

## Context
- Repo: `/Users/imranshishir/Documents/claude/AYRNOW/ayrnow-mvp`
- Remote: `git@github.com:ayrnowinc-jpg/AYRNOW-MVP.git` (private)
- Branch: `main`
- Backend: Spring Boot 3.4.4, JDK 21, Maven, PostgreSQL 16, Flyway
- JAR: `backend/target/ayrnow-backend-1.0.0-SNAPSHOT.jar`
- Architecture: Monolith, NO Docker
- Budget: Minimal cost / free tier
- Region: `us-east-1` (unless I say otherwise)

## All config files are in `claude-desktop/` folder:
```
claude-desktop/
├── DEPLOY_PROMPT.md                          ← This file (the prompt)
├── iam-policy.json                           ← IAM policy for deploy user
├── github-actions/deploy-to-eb.yml           ← GitHub Actions workflow
├── eb-config/01-environment.config           ← Elastic Beanstalk config
└── spring-aws-config/application-aws.properties ← Spring Boot AWS profile
```

## Execute these steps in order:

### Step 1: Copy config files to correct locations, commit & push
```bash
cd /Users/imranshishir/Documents/claude/AYRNOW/ayrnow-mvp

# Copy files from claude-desktop to their correct repo locations
mkdir -p .github/workflows
mkdir -p .ebextensions
cp claude-desktop/github-actions/deploy-to-eb.yml .github/workflows/deploy-to-eb.yml
cp claude-desktop/eb-config/01-environment.config .ebextensions/01-environment.config
cp claude-desktop/spring-aws-config/application-aws.properties backend/src/main/resources/application-aws.properties

# Commit & push
git add .github/workflows/deploy-to-eb.yml .ebextensions/01-environment.config backend/src/main/resources/application-aws.properties claude-desktop/
git commit -m "Add AWS Elastic Beanstalk auto-deployment pipeline"
git push origin main
```

### Step 2: Install & configure AWS CLI
Check if `aws` CLI is installed. If not, install it:
```bash
brew install awscli
```
Then run `aws configure` — prompt me for my AWS Access Key ID and Secret. Set region to `us-east-1`, output to `json`.

### Step 3: Create IAM deploy user
Use AWS CLI to create the deployment IAM user and policy:
```bash
# Create user
aws iam create-user --user-name ayrnow-deploy-bot

# Create policy from inline JSON
aws iam put-user-policy --user-name ayrnow-deploy-bot --policy-name AyrnowDeployPolicy --policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticbeanstalk:*",
        "autoscaling:*",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "elasticloadbalancing:*",
        "cloudwatch:*",
        "logs:*",
        "s3:*",
        "cloudformation:*",
        "iam:PassRole",
        "iam:GetRole",
        "iam:CreateServiceLinkedRole",
        "rds:Describe*",
        "sns:*"
      ],
      "Resource": "*"
    }
  ]
}'

# Create access keys (save the output!)
aws iam create-access-key --user-name ayrnow-deploy-bot
```
Show me the access key output so I can save it.

### Step 4: Create EB service roles
```bash
# Trust policy for EB service role
aws iam create-role --role-name aws-elasticbeanstalk-service-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "elasticbeanstalk.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

aws iam attach-role-policy --role-name aws-elasticbeanstalk-service-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService

# EC2 instance profile for EB
aws iam create-role --role-name aws-elasticbeanstalk-ec2-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

aws iam attach-role-policy --role-name aws-elasticbeanstalk-ec2-role \
  --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier

aws iam create-instance-profile --instance-profile-name aws-elasticbeanstalk-ec2-role
aws iam add-role-to-instance-profile --instance-profile-name aws-elasticbeanstalk-ec2-role --role-name aws-elasticbeanstalk-ec2-role
```

### Step 5: Create RDS PostgreSQL (free tier)
```bash
# Get default VPC and subnet info
aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<VPC_ID>" --query "Subnets[*].SubnetId" --output text

# Create DB subnet group
aws rds create-db-subnet-group \
  --db-subnet-group-name ayrnow-db-subnet \
  --db-subnet-group-description "AYRNOW RDS subnet group" \
  --subnet-ids <SUBNET_1> <SUBNET_2>

# Create security group for RDS
aws ec2 create-security-group \
  --group-name ayrnow-db-sg \
  --description "AYRNOW RDS PostgreSQL" \
  --vpc-id <VPC_ID>

# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier ayrnow-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 16 \
  --master-username ayrnow_admin \
  --master-user-password <PROMPT_ME_FOR_PASSWORD> \
  --allocated-storage 20 \
  --storage-type gp2 \
  --db-name ayrnow \
  --no-publicly-accessible \
  --vpc-security-group-ids <SG_ID> \
  --db-subnet-group-name ayrnow-db-subnet \
  --backup-retention-period 3 \
  --no-multi-az
```
Prompt me for the database password. Then wait for the RDS instance to become available (check with `aws rds describe-db-instances`). Get the endpoint when ready.

### Step 6: Create Elastic Beanstalk app + environment
```bash
# Create EB application
aws elasticbeanstalk create-application \
  --application-name ayrnow-backend \
  --description "AYRNOW MVP Backend"

# Find latest Corretto 21 platform
aws elasticbeanstalk list-available-solution-stacks | grep -i "corretto 21"

# Create environment with RDS connection
aws elasticbeanstalk create-environment \
  --application-name ayrnow-backend \
  --environment-name ayrnow-backend-env \
  --solution-stack-name "<CORRETTO_21_SOLUTION_STACK>" \
  --option-settings \
    Namespace=aws:autoscaling:launchconfiguration,OptionName=InstanceType,Value=t3.micro \
    Namespace=aws:autoscaling:launchconfiguration,OptionName=IamInstanceProfile,Value=aws-elasticbeanstalk-ec2-role \
    Namespace=aws:elasticbeanstalk:environment,OptionName=EnvironmentType,Value=SingleInstance \
    Namespace=aws:elasticbeanstalk:environment,OptionName=ServiceRole,Value=aws-elasticbeanstalk-service-role \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=SERVER_PORT,Value=5000 \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=SPRING_PROFILES_ACTIVE,Value=aws \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=SPRING_DATASOURCE_URL,Value="jdbc:postgresql://<RDS_ENDPOINT>:5432/ayrnow" \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=SPRING_DATASOURCE_USERNAME,Value=ayrnow_admin \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=SPRING_DATASOURCE_PASSWORD,Value=<DB_PASSWORD> \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=JWT_SECRET,Value=<GENERATE_RANDOM_64_CHAR_STRING> \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=STRIPE_SECRET_KEY,Value=sk_test_placeholder \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=STRIPE_WEBHOOK_SECRET,Value=whsec_placeholder \
    Namespace=aws:elasticbeanstalk:application:environment,OptionName=JAVA_TOOL_OPTIONS,Value="-Xmx512m -Xms256m -XX:+UseG1GC"
```

### Step 7: Open RDS security group to EB
```bash
# Get EB security group
aws ec2 describe-security-groups --filters "Name=group-name,Values=*ayrnow-backend*" --query "SecurityGroups[*].GroupId" --output text

# Allow EB to reach RDS on port 5432
aws ec2 authorize-security-group-ingress \
  --group-id <RDS_SG_ID> \
  --protocol tcp \
  --port 5432 \
  --source-group <EB_SG_ID>
```

### Step 8: Set GitHub secrets
```bash
# Install gh CLI if needed
brew install gh
gh auth login

# Set secrets
gh secret set AWS_ACCESS_KEY_ID --repo ayrnowinc-jpg/AYRNOW-MVP --body "<FROM_STEP_3>"
gh secret set AWS_SECRET_ACCESS_KEY --repo ayrnowinc-jpg/AYRNOW-MVP --body "<FROM_STEP_3>"
gh secret set AWS_REGION --repo ayrnowinc-jpg/AYRNOW-MVP --body "us-east-1"
gh secret set EB_APPLICATION_NAME --repo ayrnowinc-jpg/AYRNOW-MVP --body "ayrnow-backend"
gh secret set EB_ENVIRONMENT_NAME --repo ayrnowinc-jpg/AYRNOW-MVP --body "ayrnow-backend-env"
```

### Step 9: Trigger first deployment
```bash
# Make a small change to trigger the workflow, or trigger manually:
gh workflow run deploy-to-eb.yml --repo ayrnowinc-jpg/AYRNOW-MVP --ref main

# Watch the run
gh run list --repo ayrnowinc-jpg/AYRNOW-MVP --limit 1
gh run watch --repo ayrnowinc-jpg/AYRNOW-MVP
```

### Step 10: Verify
```bash
# Get EB URL
aws elasticbeanstalk describe-environments --environment-names ayrnow-backend-env --query "Environments[0].CNAME" --output text

# Test health endpoint
curl https://<EB_URL>/api/health
```

## Rules
- Prompt me for any passwords or credentials — never generate them silently
- If any step fails, diagnose and fix before moving on
- Show me the RDS endpoint and EB URL when they're ready
- If a role or resource already exists, skip creation and use the existing one
- Do NOT use Docker anywhere
