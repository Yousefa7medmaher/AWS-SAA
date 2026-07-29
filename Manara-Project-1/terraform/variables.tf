 # General
 
variable "aws_region" {
  description = "AWS region to deploy into"
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

 # VPC / networking
 
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
  description = "If true, deploy only 1 NAT Gateway (cost saver). If false, deploy 1 NAT Gateway per AZ (highly available)."
  type        = bool
  default     = true
}

 # EC2 / Launch Template
 
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

 # Auto Scaling Group
 
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

variable "asg_target_cpu_utilization" {
  description = "Target average CPU utilization (%) for the ASG target tracking scaling policy"
  type        = number
  default     = 50
}

 # ALB / Target Group
 
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
  description = "Path used by the target group health check and the Route 53 health check"
  type        = string
  default     = "/"
}

 # WAF
 
variable "waf_rate_limit" {
  description = "Max requests per 5 minutes from a single IP before WAF blocks it"
  type        = number
  default     = 2000
}

 # CloudFront / S3
 
variable "cloudfront_price_class" {
  description = "CloudFront price class (controls which edge locations are used)"
  type        = string
  default     = "PriceClass_100"
}

 # Route 53
 
variable "create_dns_records" {
  description = "Whether to create a Route 53 hosted zone and alias record for the ALB. Requires a real domain you own - keep false until you have one."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name to point at the ALB via Route 53 (only used when create_dns_records = true)"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID to reuse. Leave empty to create a new hosted zone for domain_name."
  type        = string
  default     = ""
}

 # RDS
 
variable "rds_engine_version" {
  description = "PostgreSQL engine version for RDS"
  type        = string
  default     = "16.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage for RDS, in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum storage RDS can autoscale to, in GB"
  type        = number
  default     = 100
}

variable "rds_db_name" {
  description = "Initial database name created on the RDS instance"
  type        = string
  default     = "appdb"
}

variable "rds_master_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "appadmin"
}

variable "rds_master_password" {
  description = "Master password for the RDS instance. Set a strong value in terraform.tfvars - never commit the real value to version control."
  type        = string
  sensitive   = true
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment for RDS with automated failover"
  type        = bool
  default     = true
}

variable "rds_backup_retention_days" {
  description = "Number of days to retain automated RDS backups"
  type        = number
  default     = 7
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection on the RDS instance"
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip taking a final snapshot when the RDS instance is destroyed (convenient for a lab, turn off for real production)"
  type        = bool
  default     = true
}

variable "rds_free_storage_threshold_bytes" {
  description = "CloudWatch alarm threshold for RDS free storage space, in bytes"
  type        = number
  default     = 2000000000 # ~2 GB
}

 # CloudWatch / SNS
 
variable "alert_email" {
  description = "Email address that receives SNS alarm notifications (you must confirm the subscription email AWS sends you)"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers a CloudWatch alarm (EC2 and RDS)"
  type        = number
  default     = 80
}

variable "alb_5xx_alarm_threshold" {
  description = "Number of ALB target 5xx errors in 5 minutes that triggers a CloudWatch alarm"
  type        = number
  default     = 10
}
