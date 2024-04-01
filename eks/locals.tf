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

locals {
  capacity_type = ["on-demand"]
  allowed_instance_types = [
    "m5.xlarge",
    "m5.2xlarge",
    "c5.large",
    "c5.xlarge",
    "c5.2xlarge",
    "m5.large",
  ]
  allowed_instance_type_java = [
    "m5.large",
    "m5.xlarge",
    "m5.2xlarge",
    "m5.4xlarge",
  ]
  allowed_instance_type_golang = [
    "c5.large",
    "c5.xlarge",
    "c5.2xlarge"
  ]
}


data "aws_region" "current" {}

