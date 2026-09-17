variable "region" {
  type        = string
  default     = "ap-south-1"
  description = "Region"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
  description = "CIDR Block"
}

variable "public_subnet_A" {
  type = string
  default = "10.0.1.0/24"
  description = "Public Subnet"
}

variable "public_subnet_B" {
  type = string
  default = "10.0.3.0/24"
  description = "Public Subnet"
}


variable "private_subnet_A" {
  type = string
  default = "10.0.2.0/24"
  description = "Public Subnet"
}


variable "private_subnet_B" {
  type = string
  default = "10.0.4.0/24"
  description = "Public Subnet"
}