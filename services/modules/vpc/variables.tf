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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to deploy subnets across"
  type        = number
  default     = 3
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets, one per AZ"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets, one per AZ"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT gateway for private subnet outbound traffic"
  type        = bool
  default     = true
}
