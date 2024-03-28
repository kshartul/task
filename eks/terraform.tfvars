
environment   = "dev"
region        = "us-east-1"
karpenter_chart_version = "v0.30.0"
vpc_params = {
  vpc_cidr               = "10.0.0.0/16"
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  single_nat_gateway     = false
  enable_vpn_gateway     = false
  enable_flow_log        = false
}

eks_params = {
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
}

eks_managed_node_group_params = {
  default_group = {
    min_size       = 2
    max_size       = 6
    desired_size   = 2
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    taints = [
      {
        key    = "CriticalAddonsOnly"
        value  = "true"
        effect = "NO_SCHEDULE"
      },
      {
        key    = "CriticalAddonsOnly"
        value  = "true"
        effect = "NO_EXECUTE"
      }
    ]
    max_unavailable_percentage = 50
  }
}

eks_aws_auth_users  = [
  {
    userarn  = "arn:aws:iam::784184871882:user/sh01"
    username = "sh01"
    groups   = ["system:masters"]
  }
]
karpenter_provisioner = {
  name              = "default"
  instance-family =  ["t3"]
  instance-size     = ["small", "medium", "large"]
  topology  = ["us-east-1a", "us-east-1b"]
  labels            = {
    created-by  = "karpenter"
  }
}
resource "kubectl_manifest" "karpenter_provisioner" {
  for_each = var.karpenter_provisioner

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