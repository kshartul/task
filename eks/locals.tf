locals {
  account_id  = data.aws_caller_identity.current.account_id
  name_prefix = var.environment

  tags = {
    env                        = var.environment
    eks_module_version         = "19.20.0"
    region                     = var.region
    terraform_template_version = "v1.2.0"
  }

}