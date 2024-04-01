module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"
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
}
resource "aws_iam_role" "eks_masters_access_role" {
  name = "${local.env_name}-masters-access-role"

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
    name = "${local.env_name}-masters-access-policy"

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
    Name  = "${local.env_name}-access-role"
  }
}

resource "aws_iam_role" "workernodes" {
  name = "role-${var.environment}-nodes"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.workernodes.name
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "${var.environment}-nodegroup"
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = module.vpc.private_subnets
  ami_type        = var.AMI_for_worker_nodes
  instance_types  = module.eks.instance_types
  
  scaling_config {
    desired_size = var.min_instances_node_group
    max_size     = var.max_instances_node_group
    min_size     = var.min_instances_node_group
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_eks_cluster.cluster,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_cloudwatch_log_group" "log_groups_eks" {
  name              = "/aws/eks/${var.environment}/cluster"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.kms_arn
} 

  