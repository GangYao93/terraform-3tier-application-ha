output "alb_sg_id" {
  description = "ID of the alb security group"
  value       = aws_security_group.alb.id
}

output "frontend_sg_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend.id
}

output "internal_alb_sg_id" {
  description = "ID of the internal alb security group"
  value       = aws_security_group.internal_alb.id
}

output "backend_sg_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend.id
}

output "db_sg_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "vpc_endpoint_sg_id" {
  description = "ID of the VPC endpoint security group"
  value       = aws_security_group.vpc_endpoint.id
}