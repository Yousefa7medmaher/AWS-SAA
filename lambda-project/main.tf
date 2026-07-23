terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
# S3 Buckets
resource "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
}

resource "aws_s3_bucket" "destination" {
  bucket = var.destination_bucket_name
}

# IAM Role

resource "aws_iam_role" "lambda_role" {

  name = "thumbnail-lambda-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

# IAM Policy


resource "aws_iam_role_policy" "lambda_policy" {

  name = "thumbnail-policy"

  role = aws_iam_role.lambda_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "logs:*"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.source.arn}/*"
      },

      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.destination.arn}/*"
      }

    ]

  })

}

# Lambda Layer

resource "aws_lambda_layer_version" "pillow" {

  filename            = var.layer_zip

  layer_name          = "pillow-layer"

  compatible_runtimes = ["python3.12"]

}

# Lambda Function

resource "aws_lambda_function" "thumbnail" {

  function_name = var.lambda_function_name

  role = aws_iam_role.lambda_role.arn

  runtime = var.lambda_runtime

  handler = var.lambda_handler

  filename = var.lambda_zip

  source_code_hash = filebase64sha256(var.lambda_zip)

  timeout = 30

  memory_size = 512

  layers = [
    aws_lambda_layer_version.pillow.arn
  ]

  environment {

    variables = {

      DEST_BUCKET = aws_s3_bucket.destination.bucket

    }

  }

}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {

  statement_id = "AllowExecutionFromS3"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.thumbnail.function_name

  principal = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.source.arn

}

# S3 Notification

resource "aws_s3_bucket_notification" "notification" {

  bucket = aws_s3_bucket.source.id

  lambda_function {

    lambda_function_arn = aws_lambda_function.thumbnail.arn

    events = [
      "s3:ObjectCreated:*"
    ]

  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]

}