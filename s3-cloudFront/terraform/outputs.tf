output "s3_bucket_name" {
  description = "The name of the image S3 bucket."
  value       = aws_s3_bucket.images.bucket
}

output "cloudfront_domain_name" {
  description = "The CloudFront distribution domain to use for image delivery."
  value       = aws_cloudfront_distribution.images.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.images.id
}

output "cloudfront_log_bucket" {
  description = "S3 bucket used for CloudFront access logs."
  value       = aws_s3_bucket.log_bucket.bucket
}
