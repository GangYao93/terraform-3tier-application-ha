variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_az" {
  type        = list(string)
  default     = ["us-east-1a"]
  description = "public subnet availability zone list"
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

# database configration
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

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 10
}

variable "db_engine" {
  description = "storage engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "storage engine version"
  type        = string
  default     = "15.5"
}

variable "db_instance_class" {
  description = "DB instance type"
  type        = string
  default     = "db.t3.micro"
}
variable "db_multi_az" {
  description = "is multi az deployment enable"
  type        = bool
  default     = false
}

# ECR repository arn for iam to pull image
variable "frontend_ecr_repository_arn" {
  description = "frontend ecr repository arn"
  type        = string
}

variable "backend_ecr_repository_arn" {
  description = "backend ecr repository arn"
  type        = string
}

# external alb configration
variable "external_name_prefix" {
  description = "Prefix for the ALB name (e.g., 'public-' or 'private-')"
  type        = string
  default     = ""
}

variable "external_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "external_tg_port" {
  description = "Port for the target group"
  type        = number
  default     = 3000
}

variable "external_enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "external_enable_stickiness" {
  description = "is enable stickiness"
  type        = bool
  default     = true
}

variable "external_health_check_path" {
  description = "path for health check interface"
  type        = string
  default     = "/health"
}

# internal alb configration
variable "internal_name_prefix" {
  description = "Prefix for the ALB name (e.g., 'public-' or 'private-')"
  type        = string
  default     = ""
}

variable "internal_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = true
}

variable "internal_tg_port" {
  description = "Port for the target group"
  type        = number
  default     = 8080
}

variable "internal_enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "internal_enable_stickiness" {
  description = "is enable stickiness"
  type        = bool
  default     = true
}

variable "internal_health_check_path" {
  description = "path for health check interface"
  type        = string
  default     = "/health"
}

# backend configration
variable "backend_instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "backend_docker_image" {
  type        = string
  description = "docker image url in ECR"
  default     = "245112717614.dkr.ecr.us-east-1.amazonaws.com/3-tier-with-ha/backend:latest"
}

variable "backend_min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "backend_max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 6
}

variable "backend_desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "backend_alarm_actions" {
  description = "List of ARNs for alarm actions (e.g., SNS topics)"
  type        = list(string)
  default     = []
}

variable "backend_target_cpu_value" {
  description = "target cpu of ALB"
  type        = number
  default     = 70
}

variable "backend_high_cpu_threshold" {
  description = "high cpu threshold for cloud watch"
  type        = number
  default     = 80
}

# frontend configration

variable "frontend_instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "frontend_docker_image" {
  type        = string
  description = "docker image url in ECR"
  default     = "245112717614.dkr.ecr.us-east-1.amazonaws.com/3-tier-with-ha/frontend:latest"
}

variable "frontend_min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "frontend_max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 6
}

variable "frontend_desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "frontend_alarm_actions" {
  description = "List of ARNs for alarm actions (e.g., SNS topics)"
  type        = list(string)
  default     = []
}

variable "frontend_target_cpu_value" {
  description = "target cpu of ALB"
  type        = number
  default     = 70
}

variable "frontend_high_cpu_threshold" {
  description = "high cpu threshold for cloud watch"
  type        = number
  default     = 80
}
