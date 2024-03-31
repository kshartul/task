data "aws_ecrpublic_authorization_token" "token" {}


module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  cluster_name = module.eks.cluster_name
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  create_iam_role      = false
  iam_role_arn         = module.eks.eks_managed_node_groups["default"].iam_role_arn
  irsa_use_name_prefix = false
}

data "aws_ecrpublic_authorization_token" "token" {}

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

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

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
resource "kubectl_manifest" "karpenter_provisioner" {
  for_each = toset(var.karpenter_provisioner)

  yaml_body = templatefile("${path.module}/configs/karpenter-provisioner.yaml.tmpl", {
    name = each.key
    instance-family = each.value.instance-family
    instance-size = each.value.instance-size
    topology  = each.value.topology
    taints = each.value.taints
    labels = merge(
      each.value.labels,
      {
        component   = var.component
        environment = var.environment
      }
    )
  })

  depends_on = [
    helm_release.karpenter
  ] 
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        karpenter.sh/discovery: ${local.eks_cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery: ${local.eks_cluster_name}
      tags:
        Name: ${local.eks_cluster_name}-node
        environment: ${var.environment}
        created-by: "karpneter"
        karpenter.sh/discovery: ${local.eks_cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}