variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
}
variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "naap-infra"
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "task_family" {
  description = "Task definition family name"
  type        = string
}

variable "container_image" {
  description = "Docker image URI (e.g., nginx:latest or ECR URL)"
  type        = string
}

variable "container_ports" {
  description = "List of container ports to expose"
  type        = list(number)
  default     = [80]
}

variable "cpu" {
  description = "CPU units for task (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for task in MB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of container instances"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of subnet IDs where ECS will run"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID (required for service discovery)"
  type        = string
}

# ============================================
# OPTIONAL VARIABLES
# ============================================
variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = true
}

variable "platform_version" {
  description = "Fargate platform version"
  type        = string
  default     = "LATEST"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "environment_variables" {
  description = "Environment variables for container"
  type        = map(string)
  default     = {}
}

variable "ecr_pull_required" {
  description = "Whether ECR pull permissions are needed"
  type        = bool
  default     = false
}

# ============================================
# LOAD BALANCER CONFIGURATION
# ============================================
variable "load_balancer_config" {
  description = "Load balancer configuration (target_group_arn and container_port)"
  type = object({
    target_group_arn = string
    container_port   = number
  })
  default = null
}

# ============================================
# SERVICE DISCOVERY
# ============================================
variable "enable_service_discovery" {
  description = "Enable service discovery"
  type        = bool
  default     = false
}

variable "service_discovery_namespace" {
  description = "Service discovery namespace"
  type        = string
  default     = "local"
}

# ============================================
# AUTO SCALING
# ============================================
variable "enable_autoscaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 3
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}