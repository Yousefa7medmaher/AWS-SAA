variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used for all created resources"
  type        = string
  default     = "vpc-tranist-lab"
}

variable "vpc_cidr_1" {
  description = "CIDR block for the first VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_2" {
  description = "CIDR block for the second VPC"
  type        = string
  default     = "12.0.0.0/16"
}
variable "vpc_cidr_3" {
  description = "CIDR block for the third VPC"
  type        = string
  default     = "14.0.0.0/16"
}



variable "vpc_1_subnet_1" {
  description = "CIDR block for the subnet in VPC 1"
  type        = string
  default     = "10.0.50.0/24"
}

variable "vpc_2_subnet_1" {
  description = "CIDR block for the subnet in VPC 2"
  type        = string
  default     = "12.0.50.0/24"
}



variable "vpc_3_subnet_1" {
  description = "CIDR block for the subnet in VPC 3"
  type        = string
  default     = "14.0.50.0/24"
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to reach SSH on the EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}

