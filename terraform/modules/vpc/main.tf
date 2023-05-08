module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.13.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway      = true
  single_nat_gateway      = var.single_nat_gateway
  enable_dns_hostnames    = true
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = var.tags

  # remove default inbound and outbound rules from security group
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

}