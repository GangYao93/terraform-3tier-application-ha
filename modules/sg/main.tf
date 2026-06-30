resource "aws_security_group" "alb" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for alb server - allows HTTP and HTTPS"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "frontend" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-${var.environment}-frontend-sg"
  description = "Security group for frontend server - allows request from ALB. For SSH, session manager is used, so do not need to be config"
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-frontend-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "internal_alb" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-${var.environment}-internal-alb-sg"
  description = "Security group for backend internal alb server - allows requests for frontend"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}-internal-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "backend" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-${var.environment}-backend-sg"
  description = "Security group for backend server - allows requests for internal alb"
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-sg"
    Environment = var.environment
  }
}


resource "aws_security_group" "database" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-${var.environment}-database-sg"
  description = "Security group for database - allows requests for backend"
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}-database-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "vpc_endpoint" {
  vpc_id = var.vpc_id
  name   = "${var.project_name}-${var.environment}-vpc-endpoint-sg"
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id, aws_security_group.frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

