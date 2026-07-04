output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "ec2_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private_ec2.id
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.private_ec2.private_ip
}

output "vpc_endpoint_id" {
  description = "ID of the interface VPC endpoint"
  value       = aws_vpc_endpoint.ec2.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the instance"
  value       = aws_iam_role.ec2.arn
}

output "iam_instance_profile_name" {
  description = "Name of the instance profile attached to the EC2 instance"
  value       = aws_iam_instance_profile.ec2.name
}
