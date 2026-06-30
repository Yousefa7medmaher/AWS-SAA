# S3 + CloudFront Image Delivery Architecture

## Overview
Simple provisionable AWS architecture for serving images through CloudFront from a private S3 bucket.

![Architecture Diagram](./Web%20App%20Reference%20Architecture.png)

## Architecture
- User requests an image through CloudFront.
- CloudFront delivers content over HTTPS and caches it at edge locations.
- CloudFront uses Origin Access Control (OAC) to sign requests to the private S3 bucket.
- The S3 bucket is private, encrypted, versioned, has lifecycle protection, and blocks public access.

## What this Terraform creates
- `aws_s3_bucket.images`: private image bucket with SSE-S3 encryption
- `aws_s3_bucket_ownership_controls.images`: bucket owner enforced to disable ACLs
- `aws_s3_bucket_public_access_block.images`: blocks public ACLs and policies
- `aws_s3_bucket_versioning.images`: enables versioning
- `aws_s3_bucket_lifecycle_configuration.images`: expires old object versions and aborts incomplete uploads
- `aws_s3_bucket.log_bucket`: logging bucket for CloudFront access logs
- `aws_cloudfront_origin_access_control.images_oac`: OAC for signed CloudFront-to-S3 requests
- `aws_s3_bucket_policy.images_policy`: allows CloudFront service principal access with SourceArn/SourceAccount condition
- `aws_cloudfront_distribution.images`: CloudFront distribution using managed caching and request policies

## Important correction
When using OAC, `origin_access_control_id` must be set inside the `origin` block, not inside the `s3_origin_config` block.

## Usage
1. Set the bucket name in `terraform/variables.tf` or pass it with a variable.
2. Run:
   - `terraform init`
   - `terraform apply -var="bucket_name=<your-unique-bucket-name>"

## Outputs
- `s3_bucket_name`
- `cloudfront_domain_name`
- `cloudfront_distribution_id`
- `cloudfront_log_bucket`
