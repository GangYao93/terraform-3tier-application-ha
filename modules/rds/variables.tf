# common config
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "default_tags" {
  description = "default tags"
  type        = map(string)
  default = {
    Environment = "dev"
  }
}

variable "instance_class" {
  description = "DB instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "database_subnet_ids" {
  description = "ID of the public subnet"
  type        = list(string)
}


variable "db_security_group_id" {
  description = "Security group ID for the web server"
  type        = string
}


variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 10
}

variable "engine" {
  description = "storage engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "storage engine version"
  type        = string
  default     = "15.5"
}

variable "storage_type" {
  description = "storage type"
  type        = string
  default     = "gp3"
}

variable "backup_retention_period" {
  description = "backup retention period"
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "enhanced monitoring interval"
  type        = number
  default     = 60
}

variable "multi_az" {
  description = "is multi az deployment enable"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for single-AZ deployment"
  type        = string
  default     = null
}
