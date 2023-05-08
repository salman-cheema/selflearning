variable "name" {
  description = "Name of VPC"
  type        = string
}
variable "vpc_cidr" {
  description = "Set the vpc_cidr"
  type        = string
}
variable "azs" {
  description = "AZs for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
variable "env" {
  description = "Short environment name"
  type        = string
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

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_acl_port_22" {
  default = false
}
