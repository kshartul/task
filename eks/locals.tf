locals {
  account_id  = data.aws_caller_identity.account_id
  name_prefix = var.environment

  tags = {
    env                        = var.environment
    eks_module_version         = "19.20.0"
    region                     = var.region
    terraform_template_version = "v1.2.0"
  }

  asg_tags = flatten([for k, v in module.eks.eks_managed_node_groups : [
    for l, w in local.tags : {
      sha : sha256("${k}${l}")
      name : v.node_group_autoscaling_group_names[0]
      key : l
      value : w
    }
  ] if length(v.node_group_labels) > 0])
}