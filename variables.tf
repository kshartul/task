#variable "vpc_cidr" {
#  type = string 
#}
variable "environment" {
  description = "Dev/Prod, will be used in AWS resources Name tag, and resources names"
  type        = string
}
variable "region" {
  type = string
}
variable "component" {
  description = "A team using this project (backend, web, ios, data, devops)"
  type = string
}
variable "eks_version" {
  description = "Kubernetes version, will be used in AWS resources names and to specify which EKS version to create/update"
  type        = string
}
variable "vpc_params" {
  type = object({
    vpc_cidr               = string
    enable_nat_gateway     = bool
    one_nat_gateway_per_az = bool
    single_nat_gateway     = bool
    enable_vpn_gateway     = bool
    enable_flow_log        = bool
  })
}
variable "eks_params" {
  description = "EKS cluster itslef parameters"
  type = object({
    cluster_endpoint_public_access = bool
    cluster_enabled_log_types      = list(string)
  })
}
variable "eks_managed_node_group_params" {
  description = "EKS Managed NodeGroups setting, one item in the map() per each dedicated NodeGroup"
  type = map(object({
    min_size                   = number
    max_size                   = number
    desired_size               = number
    instance_types             = list(string)
    capacity_type              = string
    taints                     = set(map(string))
    max_unavailable_percentage = number
  }))
}
variable "eks_aws_auth_users" {
  description = "IAM Users to be added to the aws-auth ConfigMap, one item in the set() per each IAM User"
  type = set(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}