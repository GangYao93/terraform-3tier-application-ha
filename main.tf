locals {
  az_count = length(var.subnet_az)
  public_subnet_cidr = [
    for i in range(local.az_count) :
    cidrsubnet(var.vpc_cidr, 8, i)
  ]
  app_subnet_cidr = [
    for i in range(local.az_count) :
    cidrsubnet(var.vpc_cidr, 8, i + 10)
  ]
  database_subnet_cidr = [
    for i in range(local.az_count) :
    cidrsubnet(var.vpc_cidr, 8, i + 20)
  ]

}

module "vpc" {
  source               = "./modules/network"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = local.public_subnet_cidr
  app_subnet_cidr      = local.app_subnet_cidr
  subnet_az            = var.subnet_az
  database_subnet_cidr = local.database_subnet_cidr
  enable_nat_gateway   = true
  single_nat_gateway   = false
}

module "sg" {
  source       = "./modules/sg"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "endpoint" {
  source              = "./modules/endpoint"
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  app_subnet_ids      = module.vpc.app_subnet_ids
  app_route_table_ids = module.vpc.app_route_table_ids
  vpc_endpoint_sg_id  = module.sg.vpc_endpoint_sg_id
}

module "rds" {
  source               = "./modules/rds"
  project_name         = var.project_name
  environment          = var.environment
  database_subnet_ids  = module.vpc.database_subnet_ids
  db_name              = var.db_name
  db_username          = var.db_username
  db_port              = var.db_port
  db_security_group_id = module.sg.db_sg_id
  instance_class       = var.db_instance_class
  multi_az             = var.db_multi_az
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  allocated_storage    = var.db_allocated_storage
}

module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
  environment  = var.environment
}

module "secrets" {
  source                         = "./modules/secrets"
  project_name                   = var.project_name
  environment                    = var.environment
  db_username                    = module.rds.db_username
  db_password                    = module.rds.db_password
  db_name                        = module.rds.db_name
  db_host                        = module.rds.db_address
  db_port                        = module.rds.db_port
  frontend_cloudwatch_group_name = module.cloudwatch.frontend_cloudwatch_group_name
  backend_cloudwatch_group_name  = module.cloudwatch.backend_cloudwatch_group_name
}

module "iam" {
  source                            = "./modules/iam"
  project_name                      = var.project_name
  environment                       = var.environment
  frontend_ecr_repository_arn       = var.frontend_ecr_repository_arn
  backend_ecr_repository_arn        = var.backend_ecr_repository_arn
  db_secret_arn                     = module.secrets.db_credentials_arn
  frontend_cloudwatch_parameter_arn = module.secrets.frontend_cloudwatch_para_arn
  backend_cloudwatch_parameter_arn  = module.secrets.backend_cloudwatch_para_arn
}

module "external_alb" {
  source                     = "./modules/alb"
  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  sg_id                      = module.sg.alb_sg_id
  subnet_ids                 = module.vpc.public_subnet_ids
  name_prefix                = var.external_name_prefix
  internal                   = var.external_internal
  tg_port                    = var.external_tg_port
  enable_deletion_protection = var.external_enable_deletion_protection
  enable_stickiness          = var.external_enable_stickiness
  health_check_path          = var.external_health_check_path
}

module "internal_alb" {
  source                     = "./modules/alb"
  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  sg_id                      = module.sg.internal_alb_sg_id
  subnet_ids                 = module.vpc.app_subnet_ids
  name_prefix                = var.internal_name_prefix
  internal                   = var.internal_internal
  tg_port                    = var.internal_tg_port
  enable_deletion_protection = var.internal_enable_deletion_protection
  enable_stickiness          = var.internal_enable_stickiness
  health_check_path          = var.internal_health_check_path
}

module "backend" {
  source                    = "./modules/backend-asg"
  project_name              = var.project_name
  environment               = var.environment
  instance_type             = var.backend_instance_type
  subnet_ids                = module.vpc.app_subnet_ids
  target_group_arn          = module.internal_alb.target_group_arn
  backend_security_group_id = module.sg.backend_sg_id
  db_credentials_arn        = module.secrets.db_credentials_arn
  iam_instance_profile_name = module.iam.backend_instance_profile_name
  cloudwatch_config_name    = module.secrets.backend_cloudwatch_para_name
  docker_image              = var.backend_docker_image
  min_size                  = var.backend_min_size
  max_size                  = var.backend_max_size
  desired_capacity          = var.backend_desired_capacity
  alarm_actions             = var.backend_alarm_actions
  high_cpu_threshold        = var.backend_high_cpu_threshold
  target_cpu_value          = var.backend_target_cpu_value
}

module "frontend" {
  source                     = "./modules/frontend-asg"
  project_name               = var.project_name
  environment                = var.environment
  instance_type              = var.frontend_instance_type
  subnet_ids                 = module.vpc.app_subnet_ids
  target_group_arn           = module.external_alb.target_group_arn
  backend_internal_url       = "http://${module.internal_alb.alb_dns_name}"
  frontend_security_group_id = module.sg.frontend_sg_id
  iam_instance_profile_name  = module.iam.frontend_instance_profile_name
  docker_image               = var.frontend_docker_image
  min_size                   = var.frontend_min_size
  max_size                   = var.frontend_max_size
  desired_capacity           = var.frontend_desired_capacity
  alarm_actions              = var.frontend_alarm_actions
  target_cpu_value           = var.frontend_target_cpu_value
  high_cpu_threshold         = var.frontend_high_cpu_threshold
  cloudwatch_config_name     = module.secrets.frontend_cloudwatch_para_name
}