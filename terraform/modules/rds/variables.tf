variable "instance_type" {
  type        = string
  description = "RDS instance type"
}

variable "env" {
  type        = string
  description = "Name of environment where RDS runs"
  default     = ""
}

variable "name" {
  type        = string
  description = "RDS name"
}

variable "username" {
  type        = string
  description = "RDS username"
}

variable "create_random_password" {
  type        = bool
  default     = true
  description = "Creates a random password instead of specified"
}

variable "password" {
  type        = string
  description = "RDS master password"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "RDS tags"
  default     = {}
}

variable "subnets" {
  type        = list(any)
  description = "RDS subnet IDs"
}

variable "vpc_id" {
  type        = string
  description = "RDS VPC ID"
}

variable "db_cluster_parameter_group_name" {
  type        = string
  description = "RDS cluster parameter group"
}

variable "db_cluster_parameter_group_family" {
  type        = string
  description = "RDS cluster parameter group family"

  validation {
    condition     = contains(["aurora-postgresql14"], var.db_cluster_parameter_group_family)
    error_message = "RDS cluster parameter group family must be aurora-mysql5.7 or aurora-postgresql13."
  }
}

variable "extra_db_cluster_parameter_group" {
  type        = list(map(string))
  description = "List containing map of parameters to apply other than local.db_cluster_parameter_group_default_parameters"
  default     = []
}

variable "deletion_protection" {
  type        = bool
  description = "RDS deletion protection"
}

variable "backup_retention_period" {
  type        = number
  description = "RDS backup retention period"
}

# variable "alarm_actions" {
#   type        = string
#   description = "SNS topic arn"
# }

variable "replica_count" {
  type        = number
  description = "RDS instance replica count"
}

variable "allowed_security_groups" {
  type        = list(any)
  description = "RDS security groups"
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster"
  type        = list(string)
  default     = []
}

variable "port" {
  type        = string
  description = "RDS port"
  default     = "3306"
}

variable "backtrack_window" {
  type        = number
  description = "Number of seconds to preserve the history of RDS changes for backtracking"
  default     = "3600"
}

variable "monitoring_interval" {
  type        = number
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to 0 to disable."
  default     = 60
}

variable "engine" {
  type        = string
  description = "RDS Aurora engine type e.g aurora-postgresql"
  default     = "aurora-postgresql"
}

variable "engine_version" {
  type        = string
  description = "RDS Aurora engine version"
  default     = "14.5"
}

variable "publicly_accessible" {
  description = "Determines whether instances are publicly accessible. Default `false`"
  type        = bool
  default     = null
}