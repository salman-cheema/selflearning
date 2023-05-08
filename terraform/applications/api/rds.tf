module "rds" {
  source                            = "../../modules/rds"
  instance_type                     = var.rds_instance_type
  port                              = var.rds_port
  env                               = local.env
  name                              = "rds"
  username                          = "dbadmin"
  vpc_id                            = module.vpc.vpc_id
  # vpc_id      = "vpc-0aca9d355c9807d68"
  deletion_protection               = var.rds_deletion_protection
  subnets                           = module.vpc.private_subnets
# subnets = ["subnet-0b9511dda4776a9ec", "subnet-0ca28b496d022545b"]
  backup_retention_period           = var.rds_backup_period
  db_cluster_parameter_group_name   = "${local.env}-parameter-group"
  db_cluster_parameter_group_family = "aurora-postgresql14"
  allowed_security_groups           = [module.sg_rds.security_group_id]
  #alarm_actions                     = try(data.terraform_remote_state.aws_global.outputs.rds_alert_arn, "")
  replica_count                     = var.rds_replicas
  vpc_security_group_ids            = [module.sg_rds.security_group_id]
  backtrack_window                  = var.backtrack_window
}