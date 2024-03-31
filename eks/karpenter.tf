data "aws_ecrpublic_authorization_token" "token" {}

module "karpenter" {
  source       = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

 node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}


resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = var.karpenter_chart_version

  set {
    name  = "settings.aws.clusterName"
    value = local.eks_cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

 # set {
 #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
 #   value = module.karpenter.irsa_arn
 # }

  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/sts-regional-endpoints"
    value = "true"
    type = "string"
  }  

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
}