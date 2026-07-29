 # Terraform & Provider Version Constraints
 # Pin Terraform and provider versions so every team member and
# CI pipeline uses the same toolchain.  Run `terraform init -upgrade`
# after changing these values.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
