variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the ALB name (e.g., 'public-' or 'private-')"
  type        = string
  default     = ""
}

variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "tg_port" {
  description = "Port for the target group"
  type        = number
  default     = 3000
}

variable "subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "sg_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}


variable "enable_stickiness" {
  description = "is enable stickiness"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "path for health check interface"
  type        = string
  default     = "/health"
}

