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

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}
