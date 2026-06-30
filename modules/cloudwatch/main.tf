resource "aws_cloudwatch_log_group" "backend" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}/backend"
  retention_in_days = 14

  tags = var.default_tags
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}/frontend"
  retention_in_days = 14

  tags = var.default_tags
}