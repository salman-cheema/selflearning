module "rates_rds_username" {
  source = "../../modules/parameter_store"
  name   = "/selflearning/${local.env}/rds/rates/username"
  value  = "rates_rw"
  overwrite = true
}

module "rates_rds_password" {
  source = "../../modules/parameter_store"
  name   = "/selflearning/${local.env}/rds/rates/password"
  value  = random_password.rates_rw_password.result
  type   = "SecureString"
  overwrite = true
}

module "master_rds_username" {
  source = "../../modules/parameter_store"
  name   = "/selflearning/${local.env}/rds/username"
  value  = module.rds.username
  overwrite = true
}

module "master_rds_password" {
  source = "../../modules/parameter_store"
  name   = "/selflearning/${local.env}/rds/password"
  value  = module.rds.password
  type   = "SecureString"
  overwrite = true
}

module "rds_endpoint" {
  source = "../../modules/parameter_store"
  name   = "/selflearning/${local.env}/rds/endpoint"
  value  = module.rds.rds_writer_internal_endpoint
  overwrite = true
}
module "rds_port" {
  source = "../../modules/parameter_store"
  name   = "/infra/${local.env}/rds/port"
  value  = module.rds.port
  overwrite = true
}