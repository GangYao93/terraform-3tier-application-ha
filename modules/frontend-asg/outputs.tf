output "asg_id" {
  value = aws_autoscaling_group.frontend.id
}

output "asg_name" {
  value = aws_autoscaling_group.frontend.name
}

output "asg_arn" {
  value = aws_autoscaling_group.frontend.arn
}

output "launch_template_id" {
  value = aws_launch_template.frontend_template.id
}

output "launch_template_last_version" {
  value = aws_launch_template.frontend_template.latest_version
}
