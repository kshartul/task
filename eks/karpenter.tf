module "karpenter" {
  source                          = "terraform-aws-modules/eks/aws//modules/karpenter"
  version                         = "19.21.0"
  cluster_name                    = module.eks.cluster_name
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  create_irsa                     = false
  create_iam_role                 = false
  iam_role_arn                    = module.karpenter_controller_irsa_role.iam_role_arn
  tags                            = local.tags
}

resource "kubernetes_namespace" "karpenter_namespace" {
  metadata {
    name = "karpenter"
  }
}