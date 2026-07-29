 # VPC, Subnets, Routing, NAT Gateway
 # A two-tier VPC: public subnets (for the ALB + NAT) and private
# subnets (for EC2 + RDS).  Everything is spread across two
# Availability Zones for high availability.

 # VPC
 resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${local.name}-vpc" })
}

 # Internet Gateway
 resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${local.name}-igw" })
}

 # Public Subnets (host ALB + NAT Gateway)
 resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "${local.name}-public-subnet-${count.index + 1}" })
}

 # Private Subnets (host EC2 + RDS)
 resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.tags, { Name = "${local.name}-private-subnet-${count.index + 1}" })
}

 # Elastic IPs for NAT Gateway(s)
 resource "aws_eip" "nat" {
  count  = var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = merge(var.tags, { Name = "${local.name}-nat-eip-${count.index + 1}" })

  depends_on = [aws_internet_gateway.igw]
}

 # NAT Gateway(s)
 # When `single_nat_gateway = true` only one NAT GW is created (cost saver).
# When false, one NAT GW per AZ is created for full HA.
resource "aws_nat_gateway" "nat" {
  count = var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, { Name = "${local.name}-nat-gw-${count.index + 1}" })

  depends_on = [aws_internet_gateway.igw]
}

 # Public Route Table (0.0.0.0/0 → IGW)
 resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "${local.name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

 # Private Route Table(s) (0.0.0.0/0 → NAT Gateway)
 resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat[0].id : aws_nat_gateway.nat[count.index].id
  }

  tags = merge(var.tags, { Name = "${local.name}-private-rt-${count.index + 1}" })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
