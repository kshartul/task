variable "vpc_cidr" {
  type = string 
}
variable "environment" {
  description = "Dev/Prod, will be used in AWS resources Name tag, and resources names"
  type        = string
}
variable "region" {
  type = string
}
variable "eks_aws_auth_users" {
  description = "IAM Users to be added to the aws-auth ConfigMap, one item in the set() per each IAM User"
  type = set(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}
variable "project_name" {
  description = "A project name to be used in resources"
  type        = string
  default     = "atlas-eks"
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
  type        = object({
    vpc_cidr  = string
  })
}
variable "region" {
  type = string
}