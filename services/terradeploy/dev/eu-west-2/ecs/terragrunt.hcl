terraform {
  source = "../../../../modules/ecs"
}

include {
  path = find_in_parent_folders("root.hcl")
}

# VPC dependency
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id            = "vpc-00000000000000000"
    public_subnet_ids = [
      "subnet-00000000000000000"
    ]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Security Group dependency
dependency "security_groups" {
  config_path = "../security_groups"

  mock_outputs = {
    security_group_ids = [
      "sg-00000000000000000"
    ]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}


inputs = {
  cluster_name       = "naap-ecs-cluster"
  task_family        = "naap-task"
  container_image    = "nginx:latest"

  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.public_subnet_ids
  security_group_ids = [dependency.security_groups.outputs.ec2_sg_id]
}