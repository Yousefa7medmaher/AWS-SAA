variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "172.16.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone in which the public subnet and EC2 instance are created"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type used for the web server"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 Key Pair used for SSH access. Leave as null to launch without a key pair."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Project name used for tagging and resource naming"
  type        = string
  default     = "CloudWatch-Terraform"
}

variable "environment" {
  description = "Deployment environment (e.g. Dev, Staging, Prod)"
  type        = string
  default     = "Dev"
}

variable "alarm_threshold" {
  description = "CPU utilization percentage threshold that triggers the high-cpu-alarm"
  type        = number
  default     = 50
}

variable "email_address" {
  description = "Email address that receives SNS notifications for CloudWatch alarms"
  type        = string
  default     = "ya1770620@gmail.com"
}
