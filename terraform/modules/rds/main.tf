locals {
  name_with_env = var.env == "" ? var.name : "${var.env}-${var.name}"
  instances = {
    for i in range(var.replica_count) : tonumber(i + 1) => {
      instance_class = var.instance_type
      promotion_tier = tonumber(i + 1)
    }
  }

  # Default parameters to be set at every RDS
  db_cluster_default_parameter_group = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ]
  db_cluster_parameter_group = concat(local.db_cluster_default_parameter_group, var.extra_db_cluster_parameter_group)
}

module "db" {
  source                              = "terraform-aws-modules/rds-aurora/aws"
  version                             = "7.3.0"
  name                                = local.name_with_env
  engine                              = var.engine
  instance_class                      = var.instance_type
  engine_version                      = var.engine_version
  vpc_id                              = var.vpc_id
  subnets                             = var.subnets
  master_username                     = var.username
  master_password                     = var.password
  port                                = var.port
  deletion_protection                 = var.deletion_protection
  create_random_password              = var.create_random_password
  copy_tags_to_snapshot               = true
  backup_retention_period             = var.backup_retention_period
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.parameter_group.name
  allowed_security_groups             = var.allowed_security_groups
  vpc_security_group_ids              = var.vpc_security_group_ids
  preferred_maintenance_window        = "sun:09:00-sun:10:00"
  preferred_backup_window             = "08:00-09:00"
  storage_encrypted                   = true
  create_monitoring_role              = true
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  auto_minor_version_upgrade          = true
  instances                           = local.instances
  apply_immediately                   = true
  iam_database_authentication_enabled = true
  create_security_group               = false
  publicly_accessible                 = var.publicly_accessible 
  backtrack_window                    = var.backtrack_window
  monitoring_interval                 = var.monitoring_interval
}

resource "aws_rds_cluster_parameter_group" "parameter_group" {
  name        = var.db_cluster_parameter_group_name
  family      = var.db_cluster_parameter_group_family
  description = "RDS Cluster Parameter Group"

  dynamic "parameter" {
    for_each = local.db_cluster_parameter_group

    content {
      apply_method = parameter.value["apply_method"]
      name         = parameter.value["name"]
      value        = parameter.value["value"]
    }
  }
  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${local.name_with_env} - CPU Utilization"
  alarm_description   = "RDS CPU Utilization Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 85
  period              = 60
  datapoints_to_alarm = 3
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
#  alarm_actions       = [var.alarm_actions]
  dimensions = {
    DBClusterIdentifier = "${local.name_with_env}"
  }
}
resource "aws_cloudwatch_metric_alarm" "db_connection_alarm" {
  alarm_name          = "${local.name_with_env} - Database Connections"
  alarm_description   = "RDS Database Connection Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 100
  period              = 60
  datapoints_to_alarm = 3
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  statistic           = "Average"
#  alarm_actions       = [var.alarm_actions]
  dimensions = {
    DBClusterIdentifier = "${local.name_with_env}"
  }
}
