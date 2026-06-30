output "frontend_cloudwatch_group_name" {
  value = aws_cloudwatch_log_group.frontend.name
}

output "backend_cloudwatch_group_name" {
  value = aws_cloudwatch_log_group.backend.name
}