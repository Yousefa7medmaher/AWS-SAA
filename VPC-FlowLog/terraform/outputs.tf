output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "Public subnet id"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet id"
  value       = aws_subnet.private.id
}

output "nat_public_ip" {
  description = "NAT gateway public IP"
  value       = aws_eip.nat_eip.public_ip
}

output "ec2_public_ip" {
  description = "EC2 public IP (if created with key)"
  value       = aws_instance.web.public_ip
}

output "flow_log_id" {
  description = "VPC Flow Log id"
  value       = aws_flow_log.vpc_flow.id
}

output "log_group_name" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_role_arn" {
  description = "IAM role ARN used by flow logs"
  value       = aws_iam_role.flow_logs_role.arn
}

