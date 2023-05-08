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

# PRE REQ
# psql-client needs to be installled at the machine from where the terraform is running
resource "null_resource" "setup_db" {
    depends_on = [ module.rds] #wait for the rds to be ready
  provisioner "local-exec" {
    command     = <<EOT
    psql 'user=${local.rates_api_username} password=${module.rates_rds_password.value} host=${module.rds_endpoint.value} dbname=postgres' -c "create database ${local.rates_api_db_name}"
    psql 'user=${local.rates_api_username} password=${module.rates_rds_password.value} host=${module.rds_endpoint.value} dbname=${local.rates_api_db_name}' -c "create user ${local.rates_api_username} with encrypted password '${random_password.rates_rw_password.result}'"
    psql 'user=${local.rates_api_username} password=${module.rates_rds_password.value} host=${module.rds_endpoint.value} dbname=${local.rates_api_db_name}' -c "grant all privileges on database ${local.rates_api_db_name} to ${local.rates_api_username}"
    psql 'user=${local.rates_api_username} password=${module.rates_rds_password.value} host=${module.rds_endpoint.value} dbname=${local.rates_api_db_name}' < files/db/rates.sql
    EOT
  }
}

