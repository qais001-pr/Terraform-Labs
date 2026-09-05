terraform {
  source = "../../../../modules/ec2"
}

include {
  path = find_in_parent_folders("root.hcl")
}


dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    public_subnet_id = "subnet-00000000000000000"
  }

  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "security_groups" {
  config_path = "../security_groups"

  mock_outputs = {
    ec2_sg_id = "sg-00000000000000000"
  }

  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  instance_type      = "t3.micro"
  root_volume_size   = 20
  subnet_id          = dependency.vpc.outputs.public_subnet_ids[0]
  security_group_ids = [dependency.security_groups.outputs.ec2_sg_id]
}