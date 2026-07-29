 # Remote State Backend (S3 + DynamoDB)
 # For production use, uncomment the block below and fill in the
# bucket / table names.  This stores the Terraform state file in
# S3 with DynamoDB-based state locking to prevent concurrent
# modifications.
#
# 1. Create the S3 bucket and DynamoDB table (one-time):
#    terraform apply -target=module.bootstrap
#    (or create them manually / via a separate script)
#
# 2. Uncomment this block, set the correct names, and run:
#    terraform init -reconfigure -backend-config="bucket=my-tfstate-bucket"
#
# backend "s3" {
#   bucket         = "my-tfstate-bucket"
#   key            = "manara-project-1/terraform.tfstate"
#   region         = "us-east-1"
#   dynamodb_table = "my-tfstate-lock"
#   encrypt        = true
# }
