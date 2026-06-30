resource "aws_secretsmanager_secret" "db_credentials" {

  name        = "${var.project_name}-${var.environment}-db-credentials"
  description = "Database password for ${var.project_name}-${var.environment}"

  lifecycle {
    # Prevent accidental deletion in production
    prevent_destroy = false
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}

resource "aws_ssm_parameter" "frontend_cloudwatch_config" {
  name        = "/${var.project_name}/${var.environment}/frontend/cloudwatch-config"
  description = "Frontend script of enable cloudwatch monitoring"

  type = "String"
  value = jsonencode({
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/user-data.log",
              log_group_name  = var.frontend_cloudwatch_group_name,
              log_stream_name = "{instance_id}/user-data"
            }
          ]
        }
      }
    },
    metrics = {
      namespace = "${var.project_name}/${var.environment}/frontend",
      metrics_collected = {
        mem = {
          measurement = [
            {
              name   = "mem_used_percent",
              rename = "MEM_USED",
              unit   = "Percent"
            }
          ],
          metrics_collection_interval = 60
        }
      }
    }
  })
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}-frontend-cloudwatch-config"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "backend_cloudwatch_config" {
  name        = "/${var.project_name}/${var.environment}/backend/cloudwatch-config"
  description = "Backend script of enable cloudwatch monitoring"

  type = "String"
  value = jsonencode({
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/user-data.log",
              log_group_name  = var.backend_cloudwatch_group_name,
              log_stream_name = "{instance_id}/user-data"
            }
          ]
        }
      }
    },
    metrics = {
      namespace = "${var.project_name}/${var.environment}/backend",
      metrics_collected = {
        mem = {
          measurement = [
            {
              name   = "mem_used_percent",
              rename = "MEM_USED",
              unit   = "Percent"
            }
          ],
          metrics_collection_interval = 60
        }
      }
    }
  })
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-cloudwatch-config"
    Environment = var.environment
  }
}
