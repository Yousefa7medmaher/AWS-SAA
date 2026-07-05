terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = var.region
}

locals {
  name = "demo-vpc-flow-log"
}

# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${local.name}-vpc" })
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${local.name}-public-subnet" })
}

# Private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnet_cidr
  tags       = merge(var.tags, { Name = "${local.name}-private-subnet" })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${local.name}-igw" })
}

# Public route table and route to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${local.name}-public-rt" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge(var.tags, { Name = "${local.name}-nat-eip" })
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags          = merge(var.tags, { Name = "${local.name}-nat" })
}

# Private route table and route to NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${local.name}-private-rt" })
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  depends_on             = [aws_nat_gateway.nat]
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name   = "${local.name}-ec2-sg"
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${local.name}-ec2-sg" })

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Find an Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 instance in public subnet
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name != "" ? var.key_name : null
  tags                   = merge(var.tags, { Name = "${local.name}-ec2" })
}

# CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/${aws_vpc.this.id}/flow-logs"
  retention_in_days = 14
  tags              = merge(var.tags, { Name = "${local.name}-log-group" })
}

# IAM role for VPC Flow Logs to write to CloudWatch
resource "aws_iam_role" "flow_logs_role" {
  name = "${local.name}-flow-log-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "vpc-flow-logs.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(var.tags, { Name = "${local.name}-flow-role" })
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "${local.name}-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc_flow" {
  vpc_id = aws_vpc.this.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_logs_role.arn

  depends_on = [
    aws_iam_role_policy.flow_logs_policy
  ]

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-flow-log"
    }
  )
}