variable "region" {
  type        = string
  default     = "ap-south-1"
  description = "Region"
}
variable "vpc_name" {
  description = "Name tag of the existing VPC"
  type        = string
  default     = "terraform-vpc-lab"
}
variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR Block"
}

variable "public_subnet_A" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Public Subnet"
}

variable "public_subnet_B" {
  type        = string
  default     = "10.0.3.0/24"
  description = "Public Subnet"
}


variable "private_subnet_A" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Public Subnet"
}


variable "private_subnet_B" {
  type        = string
  default     = "10.0.4.0/24"
  description = "Public Subnet"
}


variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "terraform-vpc-lab-cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.36"
}


variable "node_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "desired_nodes" {
  description = "Desired Number of Nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "value"
  type        = number
  default     = 2
}


variable "max_nodes" {
  description = "value"
  type        = number
  default     = 2
}


variable "node_disk_size" {
  description = "Root disk size in GB"
  type        = number
  default     = 20
}