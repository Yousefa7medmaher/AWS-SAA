 # CDN — S3 Static Assets Bucket + CloudFront Distribution
 # A private S3 bucket holds static assets (images, CSS, JS).
# CloudFront serves them at the edge via an Origin Access Control
# (OAC), so the bucket is never directly public.
#
# The CloudFront distribution has two origins:
#   1. S3  → serves /static/* (cached at the edge)
#   2. ALB → serves everything else (dynamic app traffic)

 # Random suffix for the S3 bucket name (globally unique)
 resource "random_id" "bucket_suffix" {
  byte_length = 4
}

 # S3 Bucket (private — access only via CloudFront OAC)
 resource "aws_s3_bucket" "static_assets" {
  bucket = "${local.name}-static-assets-${random_id.bucket_suffix.hex}"

  tags = merge(var.tags, { Name = "${local.name}-static-assets" })
}

# Block all public access (defense in depth).
resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce BucketOwnerEnforced (no ACLs).
resource "aws_s3_bucket_ownership_controls" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

 # CloudFront Origin Access Control (modern replacement for OAI)
 resource "aws_cloudfront_origin_access_control" "static_assets" {
  name                              = "${local.name}-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

 # CloudFront Distribution (dual-origin: S3 for /static/*, ALB for the rest)
 resource "aws_cloudfront_distribution" "app" {
  enabled     = true
  comment     = "${local.name} CDN - static assets from S3, dynamic requests via ALB"
  price_class = var.cloudfront_price_class

  # --- Origin 1: S3 static assets ---
  origin {
    domain_name              = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id                = "s3-static-assets"
    origin_access_control_id = aws_cloudfront_origin_access_control.static_assets.id
  }

  # --- Origin 2: ALB (dynamic app) ---
  origin {
    domain_name = aws_lb.app.dns_name
    origin_id   = "alb-dynamic"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # --- Default cache behavior: everything goes to the ALB ---
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "alb-dynamic"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  # --- /static/* is served from S3 and cached at the edge ---
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-static-assets"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Uses the default *.cloudfront.net certificate (HTTPS works out of the box).
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, { Name = "${local.name}-cdn" })
}

 # S3 Bucket Policy — allow CloudFront to read objects
 resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontServicePrincipal"
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.static_assets.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.app.arn
        }
      }
    }]
  })
}
