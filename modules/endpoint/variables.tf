# common config
variable "environment" {
  default     = "dev"
  description = "deploy environment"
}

variable "region" {
  default     = "us-east-1"
  description = "working region"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "default_tags" {
  description = "default tags"
  type        = map(string)
  default = {
    Environment = "dev"
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_endpoint_sg_id" {
  type        = string
  description = "VPC endpoint security group ID"
}

variable "app_subnet_ids" {
  type        = list(string)
  description = "list of app subnet id"
}

variable "app_route_table_ids" {
  type        = list(string)
  description = "list of app route table id"
}