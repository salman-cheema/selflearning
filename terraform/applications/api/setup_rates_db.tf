locals {
  rates_api_db_name = "rates"
  rates_api_username = "rates_rw"
}

resource "random_password" "rates_rw_password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  min_upper        = 1
  numeric           = true
  min_numeric      = 1
  min_special      = 3
  override_special = "@#%&?"
  depends_on = [ module.rds ]
}

output "rates_api_db_name" {
  value = local.rates_api_db_name
}

output "rates_api_username" {
  value = local.rates_api_username
}
