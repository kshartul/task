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

  output "eks_masters_access_role" {
  value = aws_iam_role.eks_masters_access_role.arn
}