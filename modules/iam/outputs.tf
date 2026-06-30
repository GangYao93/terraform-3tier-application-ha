output "frontend_role_name" {
  value = aws_iam_role.frontend.name
}

output "frontend_role_arn" {
  value = aws_iam_role.frontend.arn
}

output "frontend_instance_profile_name" {
  value = aws_iam_instance_profile.frontend.name
}

output "frontend_instance_profile_arn" {
  value = aws_iam_instance_profile.frontend.arn
}

output "backend_role_name" {
  value = aws_iam_role.backend.name
}

output "backend_role_arn" {
  value = aws_iam_role.backend.arn
}

output "backend_instance_profile_name" {
  value = aws_iam_instance_profile.backend.name
}

output "backend_instance_profile_arn" {
  value = aws_iam_instance_profile.backend.arn
}