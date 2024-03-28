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

variable "gitops_agent_token" {
  description = "token for deploying gitops agent"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "IAM role arn for cluster"
  type        = string
  default     = ""
}

variable "iam_role_use_name_prefix" {
  description = "IAM role prefix for cluster"
  type        = string
  default     = "harness"
}

variable "instance_type" {
  description = "The instance type for the EC2 node in the Managed Node Group"
  type        = string
  default     = "c5.4xlarge"
}

variable "min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = "1"
}

variable "max_size" {
  description = "Maximum number of instances/nodes"
  type        = number
  default     = "1"
}

variable "desired_size" {
  description = "Desired number of instances/nodes"
  type        = number
  default     = "1"
}

variable "region" {
  description = "EKS cluster region"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC for EKS cluster"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet ids for EKS cluster"
  type        = list(any)
  default     = []
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

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "policy_name_prefix" {
  description = "IAM policy name prefix"
  type        = string
  default     = "harness-AmazonEKS_"
}

variable "aws_route53_zone" {
  description = "Hosted zone that the DNS record will be created"
  type        = string
  default     = ""
}

variable "launch_template_name" {
  description = "Name of launch template"
  type        = string
  default     = ""
}

variable "dd_api_key" {
  description = "Datadog API key"
  type        = string
  default     = ""
}

variable "dd_app_key" {
  description = "Datadog APP key"
  type        = string
  default     = ""
}

variable "elk_role_account_id" {
  description = "The account ID of the ELK role used for FLuentbit Logging"
  type        = string
  default     = ""
}

variable "elk_role_env" {
  description = "The environment of the ELK role used for FLuentbit Logging"
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
################################################################################
# KMS Key
################################################################################

variable "create_kms_key" {
  description = "Controls if a KMS key for cluster encryption should be created"
  type        = bool
  default     = false
}
variable "kms_arn" {
  type = string
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
variable "kms_key_description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`"
  type        = number
  default     = null
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

variable "enable_kms_key_rotation" {
  description = "Specifies whether key rotation is enabled. Defaults to `true`"
  type        = bool
  default     = true
}

variable "kms_key_enable_default_policy" {
  description = "Specifies whether to enable the default key policy. Defaults to `true`"
  type        = bool
  default     = false
}

variable "kms_key_owners" {
  description = "A list of IAM ARNs for those who will have full key permissions (`kms:*`)"
  type        = list(string)
  default     = []
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(string)
  default     = []
}

variable "kms_key_users" {
  description = "A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)"
  type        = list(string)
  default     = []
}

variable "kms_key_service_users" {
  description = "A list of IAM ARNs for [key service users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration)"
  type        = list(string)
  default     = []
}

variable "kms_key_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "kms_key_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "kms_key_aliases" {
  description = "A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values"
  type        = list(string)
  default     = []
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
variable "eks_aws_auth_users" {
  description = "IAM Users to be added to the aws-auth ConfigMap, one item in the set() per each IAM User"
  type = set(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}
variable "vpc_cidr" {
  type = string   
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