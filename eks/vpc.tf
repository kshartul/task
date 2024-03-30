
#module "bootstrap" {
#  source = "git@github.com:setevoy2/terraform-bootsrap.git"
#  tfstates_s3_bucket_name = var.tfstates_s3_bucket_name
#}
module "endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.1.1"

  vpc_id = module.vpc.vpc_id

  create_security_group = true

  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
   
  endpoints = {
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags = { Name = "${var.environment}-vpc-ddb-ep" }
    }
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags = { Name = "${var.environment}-vpc-s3-ep" }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = { Name = "${var.environment}-vpc-sts-ep" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = { Name = "${var.environment}-vpc-ecr-api-ep" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = { Name = "${var.environment}-vpc-ecr-dkr-ep" }
    }
  }
}
module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = var.vpc_params.vpc_cidr
  networks = [
    {
      name     = "public-1"
      new_bits = 4
    },
    {
      name     = "public-2"
      new_bits = 4
    },
    {
      name     = "private-1"
      new_bits = 4
    },
    {
      name     = "private-2"
      new_bits = 4
    },
    {
      name     = "intra-1"
      new_bits = 8
    },
    {
      name     = "intra-2"
      new_bits = 8
    },        
  ]
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.1"
  name = "${var.environment}-vpc"
  cidr = var.vpc_params.vpc_cidr
  azs = data.aws_availability_zones.available.names
    private_subnet_tags = {
    "karpenter.sh/discovery" = local.eks_cluster_name
  }
  public_subnets  = [module.subnet_addrs.network_cidr_blocks["public-1"], module.subnet_addrs.network_cidr_blocks["public-2"]]
  private_subnets = [module.subnet_addrs.network_cidr_blocks["private-1"], module.subnet_addrs.network_cidr_blocks["private-2"]]
  intra_subnets   = [module.subnet_addrs.network_cidr_blocks["intra-1"], module.subnet_addrs.network_cidr_blocks["intra-2"]]
  enable_nat_gateway = var.vpc_params.enable_nat_gateway
  enable_vpn_gateway = var.vpc_params.enable_vpn_gateway
  enable_flow_log = var.vpc_params.enable_flow_log
}