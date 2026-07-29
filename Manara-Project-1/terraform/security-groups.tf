 # Security Groups (stateful firewalls)
 # Three security groups with a strict least-privilege chain:
#   Internet → ALB SG → EC2 SG → RDS SG

 # ALB Security Group
 # The only SG open to the internet.  Allows inbound HTTP from anywhere.
resource "aws_security_group" "alb_sg" {
  name        = "${local.name}-alb-sg"
  description = "Allow inbound HTTP from the internet to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name}-alb-sg" })
}

 # EC2 Security Group
 # Only accepts traffic from the ALB security group — never directly
# from the internet or a CIDR block.
resource "aws_security_group" "ec2_sg" {
  name        = "${local.name}-ec2-sg"
  description = "Allow inbound traffic from the ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App traffic from ALB"
    from_port       = var.target_group_port
    to_port         = var.target_group_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "All outbound (updates, NAT, RDS, SSM)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name}-ec2-sg" })
}

 # RDS Security Group
 # Only accepts PostgreSQL traffic from the EC2 security group.
resource "aws_security_group" "rds_sg" {
  name        = "${local.name}-rds-sg"
  description = "Allow Postgres traffic from EC2 instances only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name}-rds-sg" })
}
