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
      userarn  = aws_iam_role.eks_masters_access_role.arn
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

resource "aws_eks_cluster" "kube_cluster" {
  depends_on = [aws_cloudwatch_log_group.log_groups_eks]
  name       = "${var.environment}-eksClusterName"
  role_arn   = aws_iam_role.eks_masters_access_role.arn
  version    = var.cluster_version
  encryption_config {
    provider {
      key_arn = var.kms_arn
    }
    resources = ["secrets"]
  }
  enabled_cluster_log_types = var.cluster_enabled_log_types
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.private_endpoint_api
    endpoint_public_access  = var.public_endpoint_api
  }
}

################################
#####  EKS worker node role ####
################################

/*
Nodes must have a role that allows to make calls to AWS API, the role is associate to a instance profile
that is attached to EC2 instance
*/

resource "aws_iam_role" "workernodes" {
  name = "${var.environment}-role-eksNodeGroup"
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


################################
#####  EKS manage node group####
################################

/*
node group managed by eks, this contains the ec2 instances that will be the worker nodes
ec2 instances has associated the node role created before

*/
resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = "${var.environment}-eks-cluster"
  node_group_name = "${var.environment}-eksNodeGroupName"
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = var.subnet_ids
  ami_type        = var.AMI_for_worker_nodes
  instance_types  = var.instance_type_worker_nodes
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
    aws_eks_cluster.kube_cluster,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

## OIDC Config
## https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
#######################################
# Get tls certificate from EKS cluster identity issuer
#######################################

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.kube_cluster.identity[0].oidc[0].issuer
  depends_on = [
    aws_eks_cluster.kube_cluster
  ]
}

## Getting aws account ID 
data "aws_caller_identity" "id_account" {}



