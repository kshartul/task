locals {
  # create a name like 'atlas-eks-dev-1-27'
  env_name = "${var.environment}-${replace(var.eks_version, ".", "-")}"
  eks_cluster_name = "${var.environment}-cluster"
}