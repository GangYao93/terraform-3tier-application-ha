locals {
  interface_endpoints = {
    "ecr-api"        = "ecr.api"
    "ecr-dkr"        = "ecr.dkr"
    "ssm"            = "ssm"
    "ssm-messages"   = "ssmmessages"
    "ec2-messages"   = "ec2messages"
    "secretsmanager" = "secretsmanager"
    "logs"           = "logs"
    "monitoring"     = "monitoring"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = var.app_subnet_ids
  security_group_ids = [var.vpc_endpoint_sg_id]

  tags = merge(var.default_tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-endpoint"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.app_route_table_ids

  tags = merge(var.default_tags, {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
  })
}