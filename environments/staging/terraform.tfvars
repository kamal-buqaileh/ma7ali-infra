environment = "staging"
s3_lifecycle_rules = [
  {
    id              = "expire-logs"
    status          = "Enabled"
    prefix          = "logs/"
    transition_days = 30
    storage_class   = "GLACIER"
    expiration_days = 90
  }
]

# Align region with subnets' AZs (eu-central-1a/b)
aws_region = "eu-central-1"
