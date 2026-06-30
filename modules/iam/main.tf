data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "frontend" {
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  name               = "${var.project_name}-${var.environment}-frontend-role"
  tags = merge(var.default_tags, {
    Name = "${var.project_name}-${var.environment}-frontend-role"
  })
}

resource "aws_iam_role" "backend" {
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  name               = "${var.project_name}-${var.environment}-backend-role"
  tags = merge(var.default_tags, {
    Name = "${var.project_name}-${var.environment}-backend-role"
  })
}

resource "aws_iam_instance_profile" "frontend" {
  name = "${var.project_name}-${var.environment}-frontend-profile"
  role = aws_iam_role.frontend.name
}

resource "aws_iam_instance_profile" "backend" {
  name = "${var.project_name}-${var.environment}-backend-profile"
  role = aws_iam_role.backend.name
}

locals {
  ec2_roles = {
    frontend = aws_iam_role.frontend.name
    backend  = aws_iam_role.backend.name
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  for_each = local.ec2_roles

  role       = each.value
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  for_each   = local.ec2_roles
  role       = each.value
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "frontend_ecr_pull" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages"
    ]
    resources = [var.frontend_ecr_repository_arn]
  }
}

resource "aws_iam_role_policy" "frontend_ecr_pull" {
  name   = "${var.project_name}-${var.environment}-frontend-ecr-pull"
  policy = data.aws_iam_policy_document.frontend_ecr_pull.json
  role   = aws_iam_role.frontend.name
}

data "aws_iam_policy_document" "backend_ecr_pull" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages"
    ]
    resources = [var.backend_ecr_repository_arn]
  }
}

resource "aws_iam_role_policy" "backend_ecr_pull" {
  name   = "${var.project_name}-${var.environment}-backend-ecr-pull"
  policy = data.aws_iam_policy_document.backend_ecr_pull.json
  role   = aws_iam_role.backend.name
}

data "aws_iam_policy_document" "frontend_cloudwatch_parameter" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [var.frontend_cloudwatch_parameter_arn]
  }
}

resource "aws_iam_role_policy" "frontend_cloudwatch_parameter" {
  name   = "${var.project_name}-${var.environment}-frontend-cloudwatch-parameter"
  policy = data.aws_iam_policy_document.frontend_cloudwatch_parameter.json
  role   = aws_iam_role.frontend.name
}

data "aws_iam_policy_document" "backend_cloudwatch_parameter" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [var.backend_cloudwatch_parameter_arn]
  }
}

resource "aws_iam_role_policy" "backend_cloudwatch_parameter" {
  name   = "${var.project_name}-${var.environment}-backend-cloudwatch-parameter"
  policy = data.aws_iam_policy_document.backend_cloudwatch_parameter.json
  role   = aws_iam_role.backend.name
}

data "aws_iam_policy_document" "backend_secretsmanager" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.db_secret_arn]
  }
}

resource "aws_iam_role_policy" "backend_secretsmanager" {
  name   = "${var.project_name}-${var.environment}-backend-secretsmanager"
  policy = data.aws_iam_policy_document.backend_secretsmanager.json
  role   = aws_iam_role.backend.name
}