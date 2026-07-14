variable "aws_region" {
  description = "AWS region to deploy the lab into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used to tag and name all resources"
  type        = string
  default     = "my-lab"
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default = {
    Project     = "vpc-alb-asg-lab"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across (2 needed)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the 2 public subnets"
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the 2 private subnets"
  type        = list(string)
  default     = ["172.16.2.0/24", "172.16.3.0/24"]
}

variable "single_nat_gateway" {
  description = "If true, deploy only 1 NAT Gateway (cost saver for a lab). If false, deploy 1 NAT Gateway per AZ (highly available)."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type used by the launch template"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access (leave null to disable key-based SSH, e.g. when using SSM only)"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "AMI ID to use for the launch template. Leave null to auto-select the latest Amazon Linux 2023 AMI."
  type        = string
  default     = null
}



variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "alb_listener_port" {
  description = "Port the ALB listens on"
  type        = number
  default     = 80
}

variable "target_group_port" {
  description = "Port the EC2 instances / target group listen on"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path used by the target group health check"
  type        = string
  default     = "/"
}
