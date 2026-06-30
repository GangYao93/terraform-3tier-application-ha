output "db_credentials_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_name" {
  value = aws_secretsmanager_secret.db_credentials.name
}

output "frontend_cloudwatch_para_name" {
  value = aws_ssm_parameter.frontend_cloudwatch_config.name
}

output "frontend_cloudwatch_para_arn" {
  value = aws_ssm_parameter.frontend_cloudwatch_config.arn
}

output "backend_cloudwatch_para_name" {
  value = aws_ssm_parameter.backend_cloudwatch_config.name
}

output "backend_cloudwatch_para_arn" {
  value = aws_ssm_parameter.backend_cloudwatch_config.arn
}