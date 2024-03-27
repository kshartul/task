terraform {
  required_providers {
    aws = { 
      source  = "hashicorp/aws"
      version = ">= 4.6.0"
    }
  }
  required_version = ">= 1.4"
}

provider "aws" {
  region    = var.region
  profile   = "default"
    assume_role {
    role_arn = "arn:aws:iam:${local.account_id}::role/tf-admin"
  }
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["--profile", "tf-admin", "eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["--profile", "tf-admin", "eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}
provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["--profile", "tf-admin", "eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}