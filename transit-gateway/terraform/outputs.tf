output "vpc_1_id" {
  description = "ID of the first VPC"
  value       = aws_vpc.vpc_1.id
}

output "vpc_2_id" {
  description = "ID of the second VPC"
  value       = aws_vpc.vpc_2.id
}

output "vpc_3_id" {
  description = "ID of the third VPC"
  value       = aws_vpc.vpc_3.id
  
}

output "vpc_1_subnet_id" {
  description = "Subnet ID in VPC 1"
  value       = aws_subnet.vpc_1_subnet_1.id
}

output "vpc_2_subnet_id" {
  description = "Subnet ID in VPC 2"
  value       = aws_subnet.vpc_2_subnet_1.id
}
output "vpc_3_subnet_id" {
  description = "Subnet ID in VPC 3"
  value = aws_subnet.vpc_3_subnet_1.id
}


output "vpc_1_ec2_public_ip" {
  description = "Public IP of the EC2 instance in VPC 1"
  value       = aws_instance.vpc1_ec2.public_ip
}

output "vpc_2_ec2_public_ip" {
  description = "Public IP of the EC2 instance in VPC 2"
  value       = aws_instance.vpc2_ec2.public_ip
}

output "vpc_3_ec2_public_ip" {
  description = "Public IP of the EC2 instance in VPC 3"
  value       = aws_instance.vpc3_ec2.public_ip
}


output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.tgw.id
}

output "tgw_attachment_vpc_1_id" {
  description = "TGW attachment ID for VPC 1"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc_1_attachment.id
}

output "tgw_attachment_vpc_2_id" {
  description = "TGW attachment ID for VPC 2"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc_2_attachment.id
}

output "tgw_attachment_vpc_3_id" {
  description = "TGW attachment ID for VPC 3"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc_3_attachment.id
}

