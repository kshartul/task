data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "env_vpc" {
  cidr_block      = var.vpc_cidr

  tags = {
    environment = var.environment
  }
}