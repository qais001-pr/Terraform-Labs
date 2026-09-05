terraform {
  source = "../../../../modules/security_groups"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }

  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
}