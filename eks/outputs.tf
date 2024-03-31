output "eks_cloudwatch_log_group_arn" {
  value = module.eks.cloudwatch_log_group_arn
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_oidc_provider" {
  value = module.eks.oidc_provider
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "env_name" {
  value = var.environment
}
output "vpc_cidr" {
  value = var.vpc_params.vpc_cidr
}
output "vpc_public_subnets" {
  value = [module.subnet_addrs.network_cidr_blocks["public-1"], module.subnet_addrs.network_cidr_blocks["public-2"]]
}
output "vpc_private_subnets" {
  value = [module.subnet_addrs.network_cidr_blocks["private-1"], module.subnet_addrs.network_cidr_blocks["private-2"]]
}
output "vpc_intra_subnets" {
  value = [module.subnet_addrs.network_cidr_blocks["intra-1"], module.subnet_addrs.network_cidr_blocks["intra-2"]]
}

output "karpenter_aws_node_instance_profile_name" {
  value = module.karpenter.instance_profile_name
}

output "karpenter_sqs_queue_name" {
  value = module.karpenter.queue_name
}
#output "karpenter_irsa_arn" {
#  value = module.karpenter.irsa_arn
#}