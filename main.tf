module "dev_cluster" {
  source = "/eks"

  cluster_name = "dev"
}

module "staging_cluster" {
  source = "/eks"

  cluster_name = "staging"
}

module "production_cluster" {
  source = "/eks"

  cluster_name = "production"
}