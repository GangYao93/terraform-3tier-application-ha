variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "frontend_ecr_repository_arn" {
  type = string
}

variable "backend_ecr_repository_arn" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "frontend_cloudwatch_parameter_arn" {
  type = string
}

variable "backend_cloudwatch_parameter_arn" {
  type = string
}

