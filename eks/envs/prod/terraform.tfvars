
environment   = "dev"
region        = "eu-central-1"
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
    userarn  = "arn:aws:iam:${local.account_id}:user/sh01"
    username = "sh01"
    groups   = ["system:masters"]
  }
]