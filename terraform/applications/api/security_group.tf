locals {
  all_all_rule = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "sg_rds" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.9.0"
  name        = "selflearning-${local.env}-rds-sg"
  description = "${local.env} RDS security group"
  # vpc_id      = "vpc-0aca9d355c9807d68"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = local.all_all_rule
}
module "sg_ec2_bastion" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.9.0"
  name        = "selflearning-${local.env}-bastion-sg"
  description = "${local.env} Bastion security group"
  # vpc_id      = "vpc-0aca9d355c9807d68"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = local.all_all_rule
}
module "sg_rates_api" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.9.0"
  name        = "selflearning-${local.env}-rates-api-sg"
  description = "${local.env} rates-api security group"
  # vpc_id      = "vpc-0aca9d355c9807d68"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "Access ${local.env} rates-api through ALB"
      source_security_group_id = module.sg_rates_api_alb.security_group_id
    }
  ]
  egress_with_cidr_blocks = local.all_all_rule
}

module "sg_rates_api_alb" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.9.0"
  name        = "selflearning-${local.env}-rates-api-alb"
  description = "${local.env} rates-api alb security group"
  # vpc_id      = "vpc-0aca9d355c9807d68"
  vpc_id      = module.vpc.vpc_id

  ingress_rules           = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_with_cidr_blocks = local.all_all_rule
}