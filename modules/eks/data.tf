
################################################################################
#                            Data                                              #
################################################################################

data "aws_caller_identity" "current" {}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_id]
}

data "http" "eks_cluster_readiness" {
  url         = join("/", [data.aws_eks_cluster.cluster.endpoint, "healthz"])
  ca_cert_pem = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  depends_on  = [module.eks.cluster_id]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_id]
}

data "aws_route53_zone" "eks_hosted_zone" {
  name         = var.aws_route53_zone
  private_zone = true
}

data "external" "iam_role_check" {
  program = ["bash", "${path.module}/check_role.sh", "${var.env}-${var.region}-iam_role_sa"]
}
