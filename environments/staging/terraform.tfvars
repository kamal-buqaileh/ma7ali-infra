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
