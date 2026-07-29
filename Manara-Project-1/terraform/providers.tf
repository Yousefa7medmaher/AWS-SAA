 # Provider Configuration
 # The AWS provider is configured with the region defined in
# `var.aws_region`.  Additional providers (e.g. for a different
# region or account) can be added here with aliases.

provider "aws" {
  region = var.aws_region

  # Default tags applied to every resource that supports tagging.
  # This ensures consistent tagging across the entire infrastructure
  # without having to repeat `tags = var.tags` on every resource.
  default_tags {
    tags = var.tags
  }
}
