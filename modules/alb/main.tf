# Internal ALB for front to backend
resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.environment}-${var.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"

  security_groups = [var.sg_id]
  subnets         = var.subnet_ids

  idle_timeout                     = 60
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_name}-${var.environment}-${var.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.project_name}-${var.environment}-${var.name_prefix}-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  deregistration_delay = 30

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = var.enable_stickiness
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-${var.name_prefix}-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

