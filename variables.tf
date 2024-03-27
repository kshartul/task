variable "region" {
  description = "EKS cluster region"
  type        = string
  default     = ""
}
variable "environment" {
  description = "This is the environment to which the cluster is deployed"
  type        = string
  default     = ""
}

