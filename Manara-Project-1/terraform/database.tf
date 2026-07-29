 # Database — RDS PostgreSQL (Multi-AZ)
 # A single-instance PostgreSQL database with Multi-AZ standby for
# automated failover.  Deployed in the private subnets, not
# publicly accessible, with encrypted storage and automated backups.

 # DB Subnet Group (private subnets only)
 resource "aws_db_subnet_group" "app" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(var.tags, { Name = "${local.name}-db-subnet-group" })
}

 # RDS Instance
 resource "aws_db_instance" "app" {
  identifier     = "${local.name}-db"
  engine         = "postgres"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.rds_db_name
  username = var.rds_master_username
  password = var.rds_master_password

  multi_az                 = var.rds_multi_az
  db_subnet_group_name     = aws_db_subnet_group.app.name
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]
  publicly_accessible       = false

  backup_retention_period   = var.rds_backup_retention_days
  deletion_protection       = var.rds_deletion_protection
  skip_final_snapshot       = var.rds_skip_final_snapshot
  final_snapshot_identifier = var.rds_skip_final_snapshot ? null : "${local.name}-db-final-snapshot"

  tags = merge(var.tags, { Name = "${local.name}-db" })
}
