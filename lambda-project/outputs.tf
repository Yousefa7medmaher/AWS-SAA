output "source_bucket" {

  value = aws_s3_bucket.source.bucket

}

output "destination_bucket" {

  value = aws_s3_bucket.destination.bucket

}

output "lambda_name" {

  value = aws_lambda_function.thumbnail.function_name

}

output "lambda_arn" {

  value = aws_lambda_function.thumbnail.arn

}

output "lambda_role" {

  value = aws_iam_role.lambda_role.arn

}

output "layer_arn" {

  value = aws_lambda_layer_version.pillow.arn

}