variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy the infrastructure to"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, qa, staging, poc, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "staging", "poc", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, staging, poc, prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "subnet_id" {
  description = "Subnet ID to launch the EC2 instance in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instance"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access (leave empty to skip)"
  type        = string
  default     = ""
}
