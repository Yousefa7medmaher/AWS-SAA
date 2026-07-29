 # Networking
 
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  description = "ID(s) of the NAT Gateway(s)"
  value       = aws_nat_gateway.nat[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "ID(s) of the private route table(s)"
  value       = aws_route_table.private[*].id
}

output "public_nacl_id" {
  description = "ID of the public subnets' Network ACL"
  value       = aws_network_acl.public.id
}

output "private_nacl_id" {
  description = "ID of the private subnets' Network ACL"
  value       = aws_network_acl.private.id
}

 # Security
 
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL attached to the ALB"
  value       = aws_wafv2_web_acl.app.arn
}

output "ec2_iam_role_arn" {
  description = "ARN of the IAM role attached to EC2 instances (includes SSM Session Manager access)"
  value       = aws_iam_role.ec2_role.arn
}

 # Compute
 
output "launch_template_id" {
  description = "ID of the launch template used by the ASG"
  value       = aws_launch_template.app.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app.arn
}

 # Edge / static assets
 
output "s3_static_assets_bucket" {
  description = "Name of the S3 bucket used for static assets"
  value       = aws_s3_bucket.static_assets.bucket
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.app.id
}

output "cloudfront_domain_name" {
  description = "Public domain name of the CloudFront distribution - open this in a browser (works over HTTPS out of the box)"
  value       = aws_cloudfront_distribution.app.domain_name
}

 # Database
 
output "rds_endpoint" {
  description = "Connection endpoint of the RDS instance (host:port)"
  value       = aws_db_instance.app.endpoint
  sensitive   = true
}

output "rds_db_name" {
  description = "Database name created on the RDS instance"
  value       = aws_db_instance.app.db_name
}

 # DNS / monitoring
 
output "route53_health_check_id" {
  description = "ID of the Route 53 health check monitoring the ALB"
  value       = aws_route53_health_check.alb.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for CloudWatch alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.app.dashboard_name
}
