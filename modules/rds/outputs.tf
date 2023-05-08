output "host" {
  value       = module.db.cluster_endpoint
  description = "RDS hostname URL"
}

output "cluster_identifier" {
  value       = module.db.cluster_id
  description = "DB Cluster identifier"
}

output "reader_endpoint" {
  value       = module.db.cluster_reader_endpoint
  description = "RDS route53 Reader endpoint DNS record"
  sensitive   = true
}

output "rds_cluster_arn" {
  value       = module.db.cluster_arn
  description = "The ARN of the RDS instance"
}

output "password" {
  value       = module.db.cluster_master_password
  description = "RDS master password "
  sensitive   = true
}
output "username" {
  value       = module.db.cluster_master_username
  description = "RDS master username "
  sensitive   = true
}
output "port" {
  value       = var.port
  description = "RDS port"
  sensitive   = true
}

output "rds_writer_internal_endpoint" {
  value       = aws_route53_record.rds_writer_internal.fqdn
  description = "RDS route53 Writer endpoint DNS record"
  sensitive   = true
}

output "rds_reader_internal_endpoint" {
  value       = aws_route53_record.rds_reader_internal.fqdn
  description = "RDS route53 Reader endpoint DNS record"
  sensitive   = true
}