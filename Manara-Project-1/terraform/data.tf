# Data Sources & Local Values
# Data sources are read at plan time and do not create resources.
# Locals are computed values reused across multiple files.

# AZs that are actually available in the configured region.
data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Amazon Linux 2023 AMI (HVM, x86_64).
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

 # Locals — shared shorthand used throughout the configuration
 locals {
  # Use the explicitly provided AMI, or fall back to the latest AL2023.
  ami_id = coalesce(var.ami_id, data.aws_ami.amazon_linux.id)

  # Short project name used as a prefix for every resource name.
  name = var.project_name
}
