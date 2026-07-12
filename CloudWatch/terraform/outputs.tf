output "vpc_id" {
  description = "ID of the custom VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.production.dashboard_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.ec2_log_group.name
}

output "cloudwatch_alarm_name" {
  description = "Name of the high CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alarm notifications"
  value       = aws_sns_topic.alerts.arn
}
