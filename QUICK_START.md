# Quick Start Guide

## 🚀 Essential Commands

### Local Development Setup

```bash
# 1. Start LocalStack
make up

# 2. Initialize Terraform
cd environments/staging
make init

# 3. Plan infrastructure
make plan

# 4. Apply infrastructure
make apply
```

### Daily Development Workflow

```bash
# Check infrastructure status
make plan

# Apply changes
make apply

# Security check
make security

# Code quality check
make lint
```

### LocalStack Management

```bash
# Start LocalStack
make up

# Check logs
make logs

# Stop LocalStack
make down

# Restart LocalStack
make restart
```

### Security and Compliance

```bash
# Security scan
make security

# Policy compliance
make policy

# Cost estimation
make cost
```

## 🔐 Security Status

✅ **All security issues resolved**
- S3 bucket logging enabled
- MFA enforcement for all IAM groups
- Granular IAM policies (no wildcards)
- KMS encryption with key rotation

## 📊 Current Infrastructure

- **S3 Bucket**: `ma7ali-staging-{random-suffix}`
- **KMS Keys**: Main key + S3 encryption key
- **IAM Groups**: 10 groups with MFA enforcement
- **IAM Users**: 3 users (admin, developer, viewer)
- **Security**: 0 issues detected

## 🎯 Next Steps

1. **Deploy to staging**: `make apply`
2. **Test functionality**: Use AWS CLI with LocalStack
3. **Monitor security**: Run `make security` regularly
4. **Scale up**: Add production environment

---

**Need help?** Check the main [README.md](README.md) for detailed documentation. 