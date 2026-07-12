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

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  name_prefix = "${lower(var.project_name)}-${lower(var.environment)}"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block               = var.public_subnet_cidr
  availability_zone        = var.availability_zone
  map_public_ip_on_launch  = true # instances launched here get a public IP automatically

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "${local.name_prefix}-ec2-sg"
  description = "Allow SSH, HTTP, HTTPS inbound and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-sg"
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-profile"
  })
}

resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name              = "my-ec2-log-group"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "my-ec2-log-group"
  })
}

# EC2 USER DATA
# - Updates the system
# - Installs and starts Nginx
# - Installs and configures the CloudWatch Agent
#   to ship /var/log/messages, nginx access & error
#   logs to the CloudWatch Log Group
# - Enables the CloudWatch Agent to start on boot

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update the system
    dnf update -y

    # Install and enable Nginx
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx

    # Install the Amazon CloudWatch Agent
    dnf install -y amazon-cloudwatch-agent

    # Write the CloudWatch Agent configuration file
    cat <<'CWCONFIG' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "${aws_cloudwatch_log_group.ec2_log_group.name}",
                "log_stream_name": "{instance_id}/var-log-messages"
              },
              {
                "file_path": "/var/log/nginx/access.log",
                "log_group_name": "${aws_cloudwatch_log_group.ec2_log_group.name}",
                "log_stream_name": "{instance_id}/nginx-access.log"
              },
              {
                "file_path": "/var/log/nginx/error.log",
                "log_group_name": "${aws_cloudwatch_log_group.ec2_log_group.name}",
                "log_stream_name": "{instance_id}/nginx-error.log"
              }
            ]
          }
        }
      }
    }
    CWCONFIG

    # Start the CloudWatch Agent using the configuration above
    # and enable the systemd service so it survives reboots
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -s \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

    systemctl enable amazon-cloudwatch-agent
  EOF
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_pair_name
  associate_public_ip_address = true # allocate a public IP address to the instance

  user_data = local.user_data

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-server"
  })

  # Ensure the log group exists before the instance tries to write to it
  depends_on = [aws_cloudwatch_log_group.ec2_log_group]
}

resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-alerts-topic"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alerts-topic"
  })
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.alarm_threshold
  alarm_description   = "Triggers when EC2 CPUUtilization is >= ${var.alarm_threshold}% for 1 minute"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  # Publish notifications to the SNS topic when the alarm triggers or resolves
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(local.common_tags, {
    Name = "high-cpu-alarm"
  })
}

# CLOUDWATCH DASHBOARD
# Visualizes key EC2 health and performance metrics
resource "aws_cloudwatch_dashboard" "production" {
  dashboard_name = "production-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "CPU Utilization"
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.web.id]
          ]
          period = 60
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Network In"
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          metrics = [
            ["AWS/EC2", "NetworkIn", "InstanceId", aws_instance.web.id]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Network Out"
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          metrics = [
            ["AWS/EC2", "NetworkOut", "InstanceId", aws_instance.web.id]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Status Check Failed"
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          metrics = [
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", aws_instance.web.id]
          ]
          period = 60
          stat   = "Maximum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "Disk Read Bytes"
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          metrics = [
            ["AWS/EC2", "DiskReadBytes", "InstanceId", aws_instance.web.id]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title   = "Disk Write Bytes"
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          metrics = [
            ["AWS/EC2", "DiskWriteBytes", "InstanceId", aws_instance.web.id]
          ]
          period = 60
          stat   = "Sum"
        }
      }
    ]
  })
}
