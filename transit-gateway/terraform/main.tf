terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_vpc" "vpc_1" {
  cidr_block           = var.vpc_cidr_1
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc-1"
  }
}

resource "aws_vpc" "vpc_2" {
  cidr_block           = var.vpc_cidr_2
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc-2"
  }
}
resource "aws_vpc" "vpc_3" {
  cidr_block           = var.vpc_cidr_3
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc-3"
  }
}

resource "aws_subnet" "vpc_1_subnet_1" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.vpc_1_subnet_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-vpc1-subnet1"
  }
}

resource "aws_subnet" "vpc_2_subnet_1" {
  vpc_id                  = aws_vpc.vpc_2.id
  cidr_block              = var.vpc_2_subnet_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-vpc2-subnet1"
  }
}

resource "aws_subnet" "vpc_3_subnet_1" {
  vpc_id                  = aws_vpc.vpc_3.id
  cidr_block              = var.vpc_3_subnet_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-vpc3-subnet1"
  }
}


resource "aws_internet_gateway" "vpc_1_igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "${var.name_prefix}-vpc1-igw"
  }
}

resource "aws_internet_gateway" "vpc_2_igw" {
  vpc_id = aws_vpc.vpc_2.id

  tags = {
    Name = "${var.name_prefix}-vpc2-igw"
  }
}


resource "aws_internet_gateway" "vpc_3_igw" {
  vpc_id = aws_vpc.vpc_3.id

  tags = {
    Name = "${var.name_prefix}-vpc3-igw"
  }
}





resource "aws_route_table" "vpc_1_public" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_1_igw.id
  }


  tags = {
    Name = "${var.name_prefix}-vpc1-public-rt"
  }
}

resource "aws_route_table" "vpc_2_public" {
  vpc_id = aws_vpc.vpc_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_2_igw.id
  }

  tags = {
    Name = "${var.name_prefix}-vpc2-public-rt"
  }
}



resource "aws_route_table" "vpc_3_public" {
  vpc_id = aws_vpc.vpc_3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_3_igw.id
  }


  tags = {
    Name = "${var.name_prefix}-vpc3-public-rt"
  }
}

resource "aws_route_table_association" "vpc_1_assoc" {
  subnet_id      = aws_subnet.vpc_1_subnet_1.id
  route_table_id = aws_route_table.vpc_1_public.id
}

resource "aws_route_table_association" "vpc_2_assoc" {
  subnet_id      = aws_subnet.vpc_2_subnet_1.id
  route_table_id = aws_route_table.vpc_2_public.id
}

resource "aws_route_table_association" "vpc_3_assoc" {
  subnet_id      = aws_subnet.vpc_3_subnet_1.id
  route_table_id = aws_route_table.vpc_3_public.id
}

resource "aws_security_group" "vpc_1_web_sg" {
  name        = "${var.name_prefix}-vpc1-web-sg"
  description = "Allow web traffic to the VPC 1 EC2 instance"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-vpc1-web-sg"
  }
}

resource "aws_security_group" "vpc_2_web_sg" {
  name        = "${var.name_prefix}-vpc2-web-sg"
  description = "Allow web traffic to the VPC 2 EC2 instance"
  vpc_id      = aws_vpc.vpc_2.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-vpc2-web-sg"
  }
}


resource "aws_security_group" "vpc_3_web_sg" {
  name        = "${var.name_prefix}-vpc3-web-sg"
  description = "Allow web traffic to the VPC 3 EC2 instance"
  vpc_id      = aws_vpc.vpc_3.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-vpc3-web-sg"
  }
}



resource "aws_instance" "vpc1_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.vpc_1_subnet_1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.vpc_1_web_sg.id]

  user_data = <<-EOF
#!/bin/bash
set -e

dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
cat > /usr/share/nginx/html/index.html <<HTML
<html>
  <body>
    <h1>${var.name_prefix} - EC2 in VPC 1</h1>
    <p>This instance was launched from Terraform.</p>
  </body>
</html>
HTML
EOF

  tags = {
    Name = "${var.name_prefix}-ec2-vpc1"
  }
}

resource "aws_instance" "vpc2_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.vpc_2_subnet_1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.vpc_2_web_sg.id]

  user_data = <<-EOF
#!/bin/bash
set -e

dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
cat > /usr/share/nginx/html/index.html <<HTML
<html>
  <body>
    <h1>${var.name_prefix} - EC2 in VPC 2</h1>
    <p>This instance was launched from Terraform.</p>
  </body>
</html>
HTML
EOF

  tags = {
    Name = "${var.name_prefix}-ec2-vpc2"
  }
}



resource "aws_instance" "vpc3_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.vpc_3_subnet_1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.vpc_3_web_sg.id]

  user_data = <<-EOF
#!/bin/bash
set -e

dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
cat > /usr/share/nginx/html/index.html <<HTML
<html>
  <body>
    <h1>${var.name_prefix} - EC2 in VPC 3</h1>
    <p>This instance was launched from Terraform.</p>
  </body>
</html>
HTML
EOF
  tags = {
    Name = "${var.name_prefix}-ec2-vpc3"
  }
}



resource "aws_ec2_transit_gateway" "tgw" {
  description                    = "${var.name_prefix}-tgw"
  amazon_side_asn                = 64512
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "${var.name_prefix}-tgw"
  }
}



resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_1_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_1.id
  subnet_ids         = [aws_subnet.vpc_1_subnet_1.id]

  tags = {
    Name = "${var.name_prefix}-tgw-attach-vpc1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_2_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_2.id
  subnet_ids         = [aws_subnet.vpc_2_subnet_1.id]

  tags = {
    Name = "${var.name_prefix}-tgw-attach-vpc2"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_3_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_3.id
  subnet_ids         = [aws_subnet.vpc_3_subnet_1.id]

  tags = {
    Name = "${var.name_prefix}-tgw-attach-vpc3"
  }
}

# Routes: send traffic to the other VPCs through the TGW

# From VPC 1 -> VPC 2 and VPC 3
resource "aws_route" "vpc_1_to_vpc_2" {
  route_table_id         = aws_route_table.vpc_1_public.id
  destination_cidr_block = var.vpc_cidr_2
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_1_attachment]
}

resource "aws_route" "vpc_1_to_vpc_3" {
  route_table_id         = aws_route_table.vpc_1_public.id
  destination_cidr_block = var.vpc_cidr_3
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_1_attachment]
}

# From VPC 2 -> VPC 1 and VPC 3
resource "aws_route" "vpc_2_to_vpc_1" {
  route_table_id         = aws_route_table.vpc_2_public.id
  destination_cidr_block = var.vpc_cidr_1
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_2_attachment]
}

resource "aws_route" "vpc_2_to_vpc_3" {
  route_table_id         = aws_route_table.vpc_2_public.id
  destination_cidr_block = var.vpc_cidr_3
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_2_attachment]
}

# From VPC 3 -> VPC 1 and VPC 2
resource "aws_route" "vpc_3_to_vpc_1" {
  route_table_id         = aws_route_table.vpc_3_public.id
  destination_cidr_block = var.vpc_cidr_1
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_3_attachment]
}

resource "aws_route" "vpc_3_to_vpc_2" {
  route_table_id         = aws_route_table.vpc_3_public.id
  destination_cidr_block = var.vpc_cidr_2
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.vpc_3_attachment]
}


