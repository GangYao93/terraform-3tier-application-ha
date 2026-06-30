resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "#$%&*()-_=+[]{}<>:?"
}
resource "aws_db_subnet_group" "web_db_group" {
  subnet_ids = var.database_subnet_ids
  name       = "${var.project_name}-db-subnet-group"
}

resource "aws_db_parameter_group" "db_parament" {
  family = "postgres15"
  name   = "${var.project_name}-${var.environment}-pg15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-pg15"
    }
  )
}

resource "aws_db_instance" "web_db" {
  identifier     = "${var.project_name}-db"
  engine         = var.engine
  engine_version = var.engine_version

  storage_type      = var.storage_type
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = var.db_port

  vpc_security_group_ids = [var.db_security_group_id]
  parameter_group_name   = aws_db_parameter_group.db_parament.name
  db_subnet_group_name   = aws_db_subnet_group.web_db_group.name

  publicly_accessible = false
  multi_az            = var.multi_az
  availability_zone   = var.multi_az ? null : var.availability_zone

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  skip_final_snapshot = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  auto_minor_version_upgrade = true

  tags = {
    Name        = "${var.project_name}-rds"
    Environment = var.environment
  }

  depends_on = [aws_iam_role_policy_attachment.rds_monitoring]

}

data "aws_iam_policy_document" "rds_role_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["monitoring.rds.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "rds_monitoring" {
  count              = var.monitoring_interval > 0 ? 1 : 0
  name               = "${var.project_name}-${var.environment}-rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.rds_role_assume.json
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}