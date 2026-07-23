variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "source_bucket_name" {
  description = "Source bucket"
  type        = string
}

variable "destination_bucket_name" {
  description = "Destination bucket"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda Function Name"
  type        = string
  default     = "thumbnail-generator"
}

variable "lambda_runtime" {
  description = "Lambda Runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Lambda Handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_zip" {
  description = "Path to Lambda zip"
  type        = string
  default     = "./lambda/thumbnail-generator-aa2001f4-7a0a-48df-b60b-0445a2f3db25.zip"
}

variable "layer_zip" {
  description = "Path to Layer zip"
  type        = string
  default     = "./lambda/libraries.zip"
}