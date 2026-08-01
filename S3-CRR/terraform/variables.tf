# Provider regions

variable "source_region" {
  description = "AWS region where the source S3 bucket lives (the bucket that replicates data out)"
  type        = string
  default     = "eu-central-1"
}

variable "destination_region" {
  description = "AWS region where the destination S3 bucket lives (the replication target)"
  type        = string
  default     = "eu-west-1"
}

 
# IAM

variable "replication_role_name" {
  description = "Name of the IAM role assumed by S3 to perform cross-region replication"
  type        = string
  default     = "tf-iam-role-replication-12345"
}

variable "replication_policy_name" {
  description = "Name of the IAM policy attached to the replication role"
  type        = string
  default     = "tf-iam-role-policy-replication-12345"
}

# S3 buckets 

variable "source_bucket_name" {
  description = "Name of the source S3 bucket (must be unique across all of AWS)"
  type        = string
  default     = "tf-test-bucket-source-12345"
}

variable "destination_bucket_name" {
  description = "Name of the destination S3 bucket (must be unique across all of AWS)"
  type        = string
  default     = "tf-test-bucket-destination-12345"
}

 
# Replication rule
 

variable "replication_rule_id" {
  description = "Identifier for the replication rule"
  type        = string
  default     = "examplerule"
}

variable "replication_prefix" {
  description = "Object key prefix that the replication rule applies to"
  type        = string
  default     = "example"
}

variable "replication_storage_class" {
  description = "Storage class assigned to replicated objects in the destination bucket"
  type        = string
  default     = "STANDARD"
}
