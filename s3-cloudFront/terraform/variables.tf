variable "aws_region" {
  description = "AWS region for the S3 bucket and CloudFront distribution."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket used to store images. Must be globally unique."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Resource owner or team."
  type        = string
  default     = "DevOps"
}
