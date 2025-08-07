# Ma7ali Infrastructure

A secure, production-ready AWS infrastructure built with Terraform for the Ma7ali application.

## 🏗️ Architecture Overview

This infrastructure provides a complete AWS environment with the following components:

- **S3 Storage**: Secure object storage with encryption, logging, and lifecycle management
- **KMS Encryption**: Key management for data encryption and decryption
- **IAM Security**: Role-based access control with MFA enforcement
- **LocalStack Integration**: Local development environment for AWS services

## 📁 Project Structure

```
infra/
├── README.md                    # This file
├── docker-compose.yml           # LocalStack configuration
├── Makefile                     # Root-level commands
├── environments/
│   └── staging/                # Staging environment
│       ├── main.tf             # Terraform backend configuration
│       ├── providers.tf        # AWS provider with LocalStack endpoints
│       ├── variables.tf        # Environment variables
│       ├── terraform.tfvars    # Staging-specific values
│       ├── s3.tf              # S3 bucket configuration
│       ├── kms.tf             # KMS keys configuration
│       ├── iam_groups.tf      # IAM groups with MFA enforcement
│       ├── iam_policies.tf    # Granular IAM policies
│       ├── iam_users.tf       # IAM users configuration
│       ├── output.tf          # Output values
│       ├── .tfsecignore       # Security scan exclusions
│       └── Makefile           # Environment-specific commands
└── modules/
    ├── s3/                    # S3 bucket module
    ├── kms/                   # KMS key module
    ├── iam_groups/           # IAM groups module
    ├── iam_policies/         # IAM policies module
    └── iam_users/            # IAM users module
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Make](https://www.gnu.org/software/make/) (optional, for convenience)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd infra
   ```

2. **Install development tools**
   ```bash
   make install-tools
   ```

3. **Start LocalStack (for local development)**
   ```bash
   make up
   ```

4. **Initialize Terraform**
   ```bash
   cd environments/staging
   make init
   ```

5. **Plan the infrastructure**
   ```bash
   make plan
   ```

6. **Apply the infrastructure**
   ```bash
   make apply
   ```

## 🔧 Development Workflow

### Local Development

The project uses LocalStack for local AWS service simulation:

```bash
# Start LocalStack
make up

# Check LocalStack status
make logs

# Stop LocalStack
make down

# Restart LocalStack
make restart

# Clean up LocalStack data
make clean
```

### Terraform Commands

```bash
# Initialize Terraform
make init

# Plan changes
make plan

# Apply changes
make apply

# Validate configuration
make validate

# Format code
make fmt
```

### Security and Quality Checks

```bash
# Security scan (excludes false positives)
make security

# Policy compliance check
make policy

# Code linting
make lint

# Cost estimation
make cost
```

## 🔐 Security Features

### Implemented Security Measures

1. **S3 Security**
   - ✅ Server-side encryption (AES256 or KMS)
   - ✅ Access logging enabled
   - ✅ Public access blocked
   - ✅ Versioning enabled
   - ✅ Lifecycle policies for cost optimization

2. **IAM Security**
   - ✅ MFA enforcement for all groups
   - ✅ Least-privilege access policies
   - ✅ Granular permissions (no wildcards)
   - ✅ Environment-scoped resources

3. **KMS Security**
   - ✅ Key rotation enabled
   - ✅ Proper key policies
   - ✅ Separate keys for different purposes

4. **Compliance**
   - ✅ Security scanning with tfsec
   - ✅ Policy compliance with checkov
   - ✅ Code quality with tflint

### Security Scan Results

```
Results: 15 passed, 0 potential problem(s) detected.
```

## 🏛️ Infrastructure Components

### S3 Storage

- **Bucket**: `ma7ali-staging-{random-suffix}`
- **Features**:
  - Private access only
  - Server-side encryption
  - Access logging
  - Versioning
  - Lifecycle policies (logs → Glacier after 30 days, expire after 90 days)

### KMS Keys

- **Main Key**: `alias/main-key-staging`
- **S3 Key**: Dedicated key for S3 bucket encryption
- **Features**:
  - Automatic key rotation
  - Proper access policies
  - Environment-specific

### IAM Structure

#### Groups
- **admin**: Full access to S3, KMS, and IAM
- **developer**: Read/write access to S3 and KMS (no delete)
- **viewer**: Read-only access to S3 and KMS
- **s3-admin**: Full S3 access
- **s3-developer**: S3 read/write access
- **s3-viewer**: S3 read-only access
- **kms-admin**: Full KMS access
- **kms-developer**: KMS encrypt/decrypt access
- **kms-viewer**: KMS read-only access
- **iam-admin**: Full IAM access

#### Users
- **admin**: Full administrative access
- **developer**: Developer-level access
- **viewer**: Read-only access

#### Security Features
- **MFA Enforcement**: All groups require MFA
- **Granular Policies**: Specific permissions, no wildcards
- **Environment Scoping**: Resources scoped to environment

## 🎯 Usage Examples

### Accessing S3

```bash
# List buckets
aws s3 ls --endpoint-url=http://localhost:4566

# Upload file
aws s3 cp file.txt s3://ma7ali-staging-{bucket-suffix}/ --endpoint-url=http://localhost:4566

# Download file
aws s3 cp s3://ma7ali-staging-{bucket-suffix}/file.txt . --endpoint-url=http://localhost:4566
```

### Managing IAM

```bash
# List users
aws iam list-users --endpoint-url=http://localhost:4566

# List groups
aws iam list-groups --endpoint-url=http://localhost:4566

# List policies
aws iam list-policies --endpoint-url=http://localhost:4566
```

## 🔄 Environment Management

### Staging Environment

The staging environment is configured for development and testing:

- **Region**: us-east-1
- **Environment**: staging
- **Project**: ma7ali
- **Features**: Full security, logging, and monitoring

### Adding New Environments

1. Create a new directory in `environments/`
2. Copy and modify the staging configuration
3. Update `terraform.tfvars` for environment-specific values
4. Update `providers.tf` if using different AWS regions

## 🛠️ Troubleshooting

### Common Issues

1. **LocalStack Connection Issues**
   ```bash
   # Check if LocalStack is running
   docker ps | grep localstack
   
   # Restart LocalStack
   make restart
   ```

2. **Terraform State Issues**
   ```bash
   # Reinitialize Terraform
   make init
   
   # Check state
   terraform state list
   ```

3. **Security Scan Issues**
   ```bash
   # Run security scan with exclusions
   make security
   
   # Check specific issues
   tfsec . --format json
   ```

### Logs and Debugging

```bash
# View LocalStack logs
make logs

# Check Terraform logs
terraform plan -detailed-exitcode

# Debug security issues
tfsec . --verbose
```

## 📊 Monitoring and Maintenance

### Regular Tasks

1. **Security Audits**
   ```bash
   make security
   make policy
   ```

2. **Cost Monitoring**
   ```bash
   make cost
   ```

3. **Code Quality**
   ```bash
   make lint
   make fmt
   ```

### Backup and Recovery

- **S3**: Versioning enabled for object recovery
- **Terraform State**: Stored locally (consider remote state for production)
- **KMS Keys**: Proper backup and rotation policies

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Run security and quality checks**
   ```bash
   make security
   make lint
   make validate
   ```
5. **Submit a pull request**

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:

1. Check the troubleshooting section
2. Review the security documentation
3. Open an issue in the repository

## 🔄 Version History

- **v1.0.0**: Initial release with S3, KMS, and IAM infrastructure
- **v1.1.0**: Added security features (MFA, logging, granular policies)
- **v1.2.0**: Added LocalStack integration and development tools

---

**Built with ❤️ for secure, scalable infrastructure** 