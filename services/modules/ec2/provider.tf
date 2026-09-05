locals {
  default_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "${var.project_name}/ec2"
  }
}

provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
  default_tags {
    tags = local.default_tags
  }
}
