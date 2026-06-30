output "asg_id" {
  value = aws_autoscaling_group.backend.id
}

output "asg_name" {
  value = aws_autoscaling_group.backend.name
}

output "asg_arn" {
  value = aws_autoscaling_group.backend.arn
}

output "launch_template_id" {
  value = aws_launch_template.backend_template.id
}

output "launch_template_last_version" {
  value = aws_launch_template.backend_template.latest_version
}
