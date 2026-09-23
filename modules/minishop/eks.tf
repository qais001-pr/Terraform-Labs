resource "aws_eks_cluster" "minishop" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.kubernetes_version


  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.public-subnet-A.id,
      aws_subnet.public-subnet-B.id,
      aws_subnet.private-subnet-A.id,
      aws_subnet.private-subnet-B.id
    ]
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    "Name"        = var.cluster_name
    "Environment" = "lab"
    "ManagedBy"   = "Terraform"
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}


resource "aws_eks_node_group" "minishop_node_group" {
  cluster_name    = aws_eks_cluster.minishop.name
  node_group_name = "${var.cluster_name}-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.private-subnet-A.id,
    aws_subnet.private-subnet-B.id
  ]

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_nodes
    min_size     = var.min_nodes
    max_size     = var.max_nodes
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "${var.cluster_name}-node-group"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.ecr_pull_policy
  ]
}