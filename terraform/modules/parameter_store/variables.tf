variable "name" {
  type        = string
  description = "The name of parameter "
}
variable "type" {
  type        = string
  description = "Type of parameter"
  default     = "String"
}
variable "value" {
  type        = string
  description = "The value of parameter"
}
variable "key_id" {
  default     = null
  type        = string
  description = "The KMS key id or arn for encrypting a SecureString."
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for the parameters"
}
variable "ignore_value_changes" {
  type        = bool
  default     = false
  description = "Ignore changes made to a parameter value"
}
variable "overwrite" {
  type        = bool
  description = "Overwrite an existing parameter"
  default     = false
}
