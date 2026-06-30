output "db_endpoint" {
  value = aws_db_instance.web_db.endpoint
}

output "db_port" {
  value = aws_db_instance.web_db.port
}

output "db_username" {
  value = aws_db_instance.web_db.username
}
output "db_name" {
  value = aws_db_instance.web_db.db_name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "db_address" {
  value = aws_db_instance.web_db.address
}

output "db_instance_id" {
  value = aws_db_instance.web_db.id
}