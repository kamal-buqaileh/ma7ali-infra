.PHONY: install-tools init plan validate fmt check-versions lint security policy cost
.PHONY: up down restart logs shell clean

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
	tfsec .

# Run Checkov to check for compliance and policy violations
policy:
	checkov -d .

# Run Infracost to estimate cost from Terraform code
cost:
	infracost breakdown --path . --no-color


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
