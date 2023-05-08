variable "aws_account_id" {
  description = "AWS account ID where the Infrastructure deploys"
  type        = number
}

variable "vpc_cidr" {
  description = "Set the vpc_cidr"
  type        = string
}

variable "azs" {
  description = "AZs for the subnets"
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "private_subnets" {
  description = "CIDRs for the private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDRs for the public subnets"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Single nat gateway in VPC"
  type        = bool
  default     = true
}

variable "rds_instance_type" {
  default     = "db.t3.small"
  description = "RDS instance type"
}

variable "rds_replicas" {
  default     = 1
  description = "RDS replicas count "
}

variable "rds_port" {
  type        = string
  description = "RDS port"
  default     = "5432"
}

variable "backtrack_window" {
  type        = number
  description = "Number of seconds to preserve the history of RDS changes for backtracking"
  default     = 0
}

variable "rds_deletion_protection" {
  type        = bool
  description = "Enable RDS deletion protection"
  default     = false
}

variable "rds_backup_period" {
  type        = number
  description = "Number of days to store evryday RDS backup"
  default     = 30
}

variable "rate_api_image_to_deploy" {
  type        = string
  description = "In case of rool back specify required image else leave it empty"
  default = ""
}