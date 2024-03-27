##################################################################################################################
#                           IRSA Role (IAM Role for Service Accounts in EKS)                                     #
#          Configuration in this file creates IAM roles that can be assumed by multiple EKS SA for various tasks #                                      
##################################################################################################################
module "load_balancer_controller_irsa_role" {
  source                                 = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                              = "${var.cluster_name}-${var.region}-${var.environment}-load-balancer-controller"
  role_permissions_boundary_arn          = var.iam_role_permissions_boundary
  attach_load_balancer_controller_policy = true
  policy_name_prefix                     = var.policy_name_prefix
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  tags = local.tags
}

module "external_dns_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                     = "${var.cluster_name}-${var.region}-${var.environment}-ExternalDNSService"
  role_permissions_boundary_arn = var.iam_role_permissions_boundary
  external_dns_hosted_zone_arns = [data.aws_route53_zone.eks_hosted_zone.arn]
  policy_name_prefix            = var.policy_name_prefix
  attach_external_dns_policy    = true
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
  tags = local.tags
}

module "vpc_cni_ipv4_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                     = "${var.cluster_name}-${var.region}-${var.environment}-vpc-cni-ipv4"
  attach_vpc_cni_policy         = true
  policy_name_prefix            = var.policy_name_prefix
  role_permissions_boundary_arn = var.iam_role_permissions_boundary
  vpc_cni_enable_ipv4           = true
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = local.tags
}

module "ebs_csi_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                     = "${var.cluster_name}-${var.region}-${var.environment}-ebs-csi"
  attach_ebs_csi_policy         = true
  policy_name_prefix            = var.policy_name_prefix
  role_permissions_boundary_arn = var.iam_role_permissions_boundary
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = local.tags
}

module "cluster_autoscaler_irsa_role" {
  source                           = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                        = "${var.cluster_name}-${var.region}-${var.environment}-cluster-autoscaler"
  policy_name_prefix               = var.policy_name_prefix
  role_permissions_boundary_arn    = var.iam_role_permissions_boundary
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
  tags = local.tags
}

module "karpenter_controller_irsa_role" {
  source                             = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                          = "${var.cluster_name}-${var.region}-${var.environment}-karpenter-controller"
  role_permissions_boundary_arn      = var.iam_role_permissions_boundary
  attach_karpenter_controller_policy = true
  policy_name_prefix                 = var.policy_name_prefix
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
  tags = local.tags
}