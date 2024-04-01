variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "eks_version" {
  description = "Kubernetes version, will be used in AWS resources names and to specify which EKS version to create/update"
  type        = string
  default     = "1.29"
}
variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "ami_version" {
  description = "AMI version"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.29"
}

variable "role_arn" {
  description = "IAM role arn for cluster"
  type        = string
  default     = ""
}

variable "region" {
  description = "EKS cluster region"
  type        = string
  default     = ""
}

variable "tags" {
  description = "List of tags for EKS cluster"
  type        = map(any)
  default     = {}
}

variable "eks_module_version" {
  description = "Terraform module version"
  type        = string
  default     = ""
}

variable "environment" {
  description = "This is the environment to which the cluster is deployed"
  type        = string
  default     = ""
}

variable "iam_role_permissions_boundary" {
  description = "EKS iam_role_permissions_boundary"
  type        = string
  default     = ""
}

variable "node_group_name" {
  type    = string
  default = "cwa-dev"
}

variable "aws_auth_roles" {
  type    = list(any)
  default = []
}

variable "bucket" {
  description = "Bucket to store terraform statefile"
  type        = string
  default     = ""
}

variable "bucket_key" {
  description = "Bucket key/path to store terraform statefile"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of az for EKS cluster"
  type        = list(any)
  default     = []
}

variable "subnet_ids_eks_custom" {
  description = "List of subnet ids for custom network setup for pods"
  type        = list(any)
  default     = []
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}
variable "private_endpoint_api" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "public_endpoint_api" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "AMI_for_worker_nodes" {
  description = "the AWS AMI to use in the worker nodes"
  type        = string
  default     = "AL2_x86_64"
}
variable "instance_type_worker_nodes" {
  description = "the instances types to use for eks worker nodes"
  type        = string
  default     = "t3.medium"
}
variable "min_instances_node_group" {
  description = "minimum number of instance to use in the node group"
  type        = number
  default     = 1
}

variable "max_instances_node_group" {
  description = "max number of instance to use in the node group"
  type        = number
   default     = 2
}
################################################################################
# CloudWatch Log Group
################################################################################


variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
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

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version to be installed"
  type        = string
}

variable "karpenter_provisioner" {
  type = list(object({
    name              = string
    instance-family = list(string)
    instance-size     = list(string)
    topology  = list(string)
    labels            = optional(map(string))
    taints = optional(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
}
variable "component" {
  description = "Karpenter provisioner component"
  type        = string
}

