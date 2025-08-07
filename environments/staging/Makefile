.PHONY: install-tools init plan validate fmt check-versions lint security policy cost
.PHONY: up down restart logs shell clean resource

init:
	terraform init

plan:
	AWS_S3_FORCE_PATH_STYLE=true terraform plan

validate:
	terraform validate

fmt:
	terraform fmt -recursive

install-tools:
	brew install terraform # Infrastructure as Code (IaC) tool
	brew install tflint    # Linting for Terraform files
	brew install tfsec     # Scans your Terraform code for security vulnerabilities
	brew install checkov   # Static analysis and policy checks
	brew install infracost # Cost estimation and visualization

check-versions:
	terraform -v
	tflint --version
	tfsec --version
	checkov --version
	infracost --version

# Run TFLint to check formatting and best practices
lint:
	tflint

# Run tfsec to check for security vulnerabilities
security:
	tfsec . --exclude aws-iam-no-policy-wildcards,aws-s3-enable-versioning,aws-ec2-no-public-ip-subnet,aws-iam-enforce-group-mfa,aws-ec2-require-vpc-flow-logs-for-all-vpcs

# Run Checkov to check for compliance and policy violations
policy:
	checkov -d .

# Run Infracost to estimate cost from Terraform code
cost:
	infracost breakdown --path . --no-color

# Create a new resource and its corresponding module
# Usage: make resource <resource-name>
# Example: make resource vpc
resource:
	@mkdir -p ../../modules/$(word 2,$(MAKECMDGOALS))
	@echo "# $(word 2,$(MAKECMDGOALS)) module" > ../../modules/$(word 2,$(MAKECMDGOALS))/main.tf
	@echo "# $(word 2,$(MAKECMDGOALS)) module variables" > ../../modules/$(word 2,$(MAKECMDGOALS))/variables.tf
	@echo "# $(word 2,$(MAKECMDGOALS)) module outputs" > ../../modules/$(word 2,$(MAKECMDGOALS))/outputs.tf
	@echo "# $(word 2,$(MAKECMDGOALS)) README" > ../../modules/$(word 2,$(MAKECMDGOALS))/README.md
	@echo "# $(word 2,$(MAKECMDGOALS)) configuration" > $(word 2,$(MAKECMDGOALS)).tf
	@echo "✅ Created $(word 2,$(MAKECMDGOALS)) resource and module!"

# Catch-all target to prevent errors when resource names are passed
%:
	@:

# Start LocalStack
up:
	docker-compose up -d

# Stop LocalStack
down:
	docker-compose down

# Restart LocalStack
restart:
	docker-compose down && docker-compose up -d

# Tail logs
logs:
	docker logs -f localstack

# Shell into the container
shell:
	docker exec -it localstack /bin/bash

# Wipe LocalStack volume
clean:
	docker-compose down -v
