data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "frontend_template" {
  name_prefix   = "${var.project_name}-${var.environment}-frontend-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  # todo add key pair config
  #key_name = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  vpc_security_group_ids = [var.frontend_security_group_id]

  user_data = base64encode(templatefile("${path.module}/userdata/frontend_userdata.sh", {
    docker_image           = var.docker_image
    backend_internal_url   = var.backend_internal_url
    region                 = var.region
    environment            = var.environment
    project                = var.project_name
    cloudwatch_config_name = var.cloudwatch_config_name
  }))

  block_device_mappings {
    device_name = data.aws_ami.ubuntu.root_device_name
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-frontend"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.project_name}-${var.environment}-front-volume"
    }
  }
}

resource "aws_autoscaling_group" "frontend" {
  name_prefix               = "${var.project_name}-${var.environment}-frontend-asg-"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 600
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.frontend_template.id
    version = aws_launch_template.frontend_template.latest_version
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.project_name}-${var.environment}-frontend"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "frontend_cpu" {
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  name                   = "${var.project_name}-${var.environment}-frontend-cpu-tracking"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = var.target_cpu_value
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "front_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-frontend-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.high_cpu_threshold
  alarm_description   = "Front EC2 average CPU utilization is high"
  alarm_actions       = var.alarm_actions
  treat_missing_data  = "notBreaching"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.frontend.name
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-frontend-high-cpu"
  }
}

# CloudWatch Alarm - Unhealthy Hosts
resource "aws_cloudwatch_metric_alarm" "frontend_unhealthy" {
  alarm_name          = "${var.project_name}-${var.environment}-frontend-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when frontend instances are unhealthy"
  alarm_actions       = var.alarm_actions

  dimensions = {
    TargetGroup = split(":", var.target_group_arn)[5]
  }

}

