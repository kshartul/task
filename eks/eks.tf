module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  cluster_name    = "${var.environment}-eks-cluster"
  cluster_version = var.eks_version
  cluster_endpoint_public_access = var.eks_params.cluster_endpoint_public_access
  cluster_enabled_log_types = var.eks_params.cluster_enabled_log_types

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  manage_aws_auth_configmap = true

  eks_managed_node_groups = {
    default = {

      min_size       = var.eks_managed_node_group_params.default_group.min_size
      max_size       = var.eks_managed_node_group_params.default_group.max_size
      desired_size   = var.eks_managed_node_group_params.default_group.desired_size
      instance_types = var.eks_managed_node_group_params.default_group.instance_types
      capacity_type  = var.eks_managed_node_group_params.default_group.capacity_type

      taints = var.eks_managed_node_group_params.default_group.taints

      update_config = {
        max_unavailable_percentage = var.eks_managed_node_group_params.default_group.max_unavailable_percentage
      }
    }
  }

  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }
  aws_auth_users = var.eks_aws_auth_users
  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_masters_access_role.arn
      username = aws_iam_role.eks_masters_access_role.arn
      groups   = ["system:masters"]
    }
  ]
}
resource "aws_iam_role" "eks_masters_access_role" {
  name = "${var.environment}-masters-access-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.environment}-masters-access-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["eks:DescribeCluster*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }  

  tags = {
    Name  ="${var.environment}-access-role"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_masters_access_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_masters_access_role.name
}
resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.eks_masters_access_role.name
}
data "aws_caller_identity" "current" {}