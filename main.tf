module "dev_cluster" {
  source = "./eks/main"

  cluster_name = "dev"
}

