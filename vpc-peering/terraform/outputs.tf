output "vpc_1_id" {
  description = "ID of the first VPC"
  value       = aws_vpc.vpc_1.id
}

output "vpc_2_id" {
  description = "ID of the second VPC"
  value       = aws_vpc.vpc_2.id
}

output "vpc_1_subnet_id" {
  description = "Subnet ID in VPC 1"
  value       = aws_subnet.vpc_1_subnet_1.id
}

output "vpc_2_subnet_id" {
  description = "Subnet ID in VPC 2"
  value       = aws_subnet.vpc_2_subnet_1.id
}

output "vpc_1_ec2_public_ip" {
  description = "Public IP of the EC2 instance in VPC 1"
  value       = aws_instance.vpc1_ec2.public_ip
}

output "vpc_2_ec2_public_ip" {
  description = "Public IP of the EC2 instance in VPC 2"
  value       = aws_instance.vpc2_ec2.public_ip
}

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.id
}