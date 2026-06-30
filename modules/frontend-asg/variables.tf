variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  type = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "target_group_arn" {
  description = "List of Target Group ARNs to attach to the ASG"
  type        = string
}
variable "backend_internal_url" {
  description = "connection information for backend"
  type        = string
}

variable "frontend_security_group_id" {
  description = "Security group ID for the web server"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 to access Secrets Manager"
  type        = string
}

variable "docker_image" {
  type        = string
  description = "docker image url in ECR"
  default     = "245112717614.dkr.ecr.us-east-1.amazonaws.com/3-tier-with-ha/frontend:latest"
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (e.g., SNS topics)"
  type        = list(string)
  default     = []
}

variable "target_cpu_value" {
  description = "target cpu of ALB"
  type        = number
  default     = 70
}

variable "high_cpu_threshold" {
  description = "high cpu threshold for cloud watch"
  type        = number
  default     = 80
}

variable "cloudwatch_config_name" {
  type        = string
  description = "could watch configration"
}