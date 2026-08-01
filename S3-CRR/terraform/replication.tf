resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.central
  # Bucket versioning must be enabled before replication can be configured
  depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.source.id

  rule {
    id = var.replication_rule_id

    filter {
      prefix = var.replication_prefix
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = var.replication_storage_class
    }
  }
}
