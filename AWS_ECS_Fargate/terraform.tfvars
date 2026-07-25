aws_region           = "us-east-1"
project_name         = "demo-lab"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]

container_name       = "web-app"
container_image      = "yousef2005/web-app:v1"
container_port       = 8080

task_cpu             = "256"
task_memory          = "512"
desired_count        = 2
log_retention_days   = 7
