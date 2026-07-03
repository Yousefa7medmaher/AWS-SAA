terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

locals {
  azs           = slice(data.aws_availability_zones.available.names, 0, 2)
  public_cidrs  = ["10.0.50.0/24", "10.0.51.0/24"]
  private_cidrs = ["10.0.100.0/24", "10.0.101.0/24"]
  common_tags = {
    Project     = "network-lab"
    Environment = "lab"
  }
}

resource "aws_vpc" "example" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "network-lab-vpc"
  })
}

resource "aws_subnet" "public" {
  for_each = zipmap(local.azs, local.public_cidrs)

  vpc_id                  = aws_vpc.example.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "public-${each.key}"
  })
}

resource "aws_subnet" "private" {
  for_each = zipmap(local.azs, local.private_cidrs)

  vpc_id            = aws_vpc.example.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(local.common_tags, {
    Name = "private-${each.key}"
  })
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = merge(local.common_tags, {
    Name = "network-lab-igw"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = merge(local.common_tags, {
    Name = "public-route-table"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(local.common_tags, {
    Name = "nat-gateway-${each.key}"
  })

  depends_on = [aws_internet_gateway.example]
}

resource "aws_route_table" "private_rt" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = merge(local.common_tags, {
    Name = "private-route-table-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}
