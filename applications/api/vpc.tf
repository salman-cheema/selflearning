module "vpc" {
  source              = "../../modules/vpc"
  name                = "${local.env}-vpc"
  vpc_cidr            = var.vpc_cidr
  env                 = local.env
  azs                 = var.azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  single_nat_gateway  = var.single_nat_gateway
}
