
locals {
  all_all_rule = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
module "sg_run_ecs_batch_job_lambda" {
  count                   = can(data.terraform_remote_state.rates_api_app.outputs.vpc_id) ? 1 : 0
  source                  = "terraform-aws-modules/security-group/aws"
  version                 = "4.9.0"
  name                    = "${local.env}-selflearning-ecs-lambda-sg"
  description             = "selflearning ecs lambda security group"
  vpc_id                  = data.terraform_remote_state.rates_api_app.outputs.vpc_id
  egress_with_cidr_blocks = local.all_all_rule
}

module "sg_rates_batch_job_ecs_task" {
  count                   = can(data.terraform_remote_state.rates_api_app.outputs.vpc_id) ? 1 : 0
  source                  = "terraform-aws-modules/security-group/aws"
  version                 = "4.9.0"
  name                    = "${local.env}-selflearning-rates-batch-jobs-sg"
  description             = "selflearning rates batch jobs security group"
  vpc_id                  = data.terraform_remote_state.rates_api_app.outputs.vpc_id
  egress_with_cidr_blocks = local.all_all_rule
}

resource "aws_security_group_rule" "batch_job_access_to_rds" {
  count                   = can(data.terraform_remote_state.rates_api_app.outputs.sg_rds_id) ? 1 : 0
  description              = "Access to ${local.env}-rds from ${local.env}-rates-batch-jobs"
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  source_security_group_id = module.sg_rates_batch_job_ecs_task[0].security_group_id
  security_group_id        = data.terraform_remote_state.rates_api_app.outputs.sg_rds_id
}