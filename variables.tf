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
