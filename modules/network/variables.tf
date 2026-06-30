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

# network config
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "vpc cidr"
}

# subnet config
variable "public_subnet_cidr" {
  default     = ["10.0.1.0/24"]
  type        = list(string)
  description = "public subnet cidr list"
}

variable "subnet_az" {
  type        = list(string)
  default     = ["us-east-1a"]
  description = "public subnet availability zone list"
}

variable "app_subnet_cidr" {
  default     = ["10.0.2.0/24"]
  type        = list(string)
  description = "front subnet cidr"
}

variable "database_subnet_cidr" {
  default     = ["10.0.2.0/24"]
  type        = list(string)
  description = "private subnet cidr"
}

# NAT config
variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "is enable nate gateway"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "is use signal nat gateway for all private subnet"
}





