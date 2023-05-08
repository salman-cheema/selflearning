locals {
  rates_api_db_name = "rates"
  rates_api_username = "rates_rw"
}
# resource "postgresql_database" "rates" {
#   name              = local.rates_api_db_name
#   depends_on = [ module.rds,
#    aws_route53_zone.internal_selflearning]
# }

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

# resource "postgresql_role" "rates_rw_role" {
#   name     = local.rates_api_username
#   login    = true
#   password = random_password.rates_rw_password.result
#   depends_on = [ module.rds ]
# }

# PRE REQ
# psql-client needs to be installled at the machine from where the terraform is running
resource "null_resource" "setup_db" {
    depends_on = [ module.rds,
   postgresql_database.rates ] #wait for the rds to be ready
  provisioner "local-exec" {
    command     = <<EOT
    psql 'user=${local.rates_api_username} password=${module.rates_rds_password.value} host=${module.rds.rds_writer_internal_endpoint} dbname=${local.rates_api_db_name}' -c "create database ${local.rates_api_db_name}"
    psql 'user=${local.rates_api_username} password=${module.rates_rds_password.value} host=${module.rds.rds_writer_internal_endpoint} dbname=${local.rates_api_db_name}' < files/db/rates.sql
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

