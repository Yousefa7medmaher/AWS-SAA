variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for demo"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional key pair name for SSH access"
  type        = string
  default     = ""
}

variable "tags" {
  type = map(string)
  default = {
    Terraform = "true"
    Project   = "demo-vpc-flow-log"
  }
}

