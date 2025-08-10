# acm module variables

variable "domain_name" {
  type        = string
  description = "The domain name for the certificate"
  validation {
    condition     = can(regex("^[a-z0-9.*-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format (e.g., example.com or *.example.com)."
  }
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domain names for the certificate (SANs)"
  default     = []
}

variable "hosted_zone_id" {
  type        = string
  description = "The Route53 hosted zone ID for DNS validation"
}

variable "validation_method" {
  type        = string
  description = "Method to use for certificate validation (DNS or EMAIL)"
  default     = "DNS"
  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "Validation method must be either DNS or EMAIL."
  }
}

variable "key_algorithm" {
  type        = string
  description = "The algorithm for the certificate's private key"
  default     = "RSA_2048"
  validation {
    condition = contains([
      "RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096",
      "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"
    ], var.key_algorithm)
    error_message = "Key algorithm must be a valid AWS ACM supported algorithm."
  }
}

variable "certificate_transparency_logging_preference" {
  type        = string
  description = "Certificate transparency logging preference"
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.certificate_transparency_logging_preference)
    error_message = "Certificate transparency logging preference must be ENABLED or DISABLED."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to ACM certificate"
  default     = {}
}
