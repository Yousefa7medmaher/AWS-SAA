variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for all resources (VPC name = demo-lab)"
  type        = string
  default     = "demo-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the 2 public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "container_name" {
  description = "Name of the container inside the task definition"
  type        = string
  default     = "web-app"
}

variable "container_image" {
  description = "Docker Hub image to run (repo:tag)"
  type        = string
  default     = "yousef2005/web-app:v1"
}

variable "container_port" {
  description = "Port the container listens on (also used by SG, target group, listener)"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of ECS tasks to run (one per public subnet by default)"
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 7
}
