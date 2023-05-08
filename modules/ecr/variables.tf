variable "name" {
  type        = string
  description = "The name of repository"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "read_write_access_arns" {
  type        = list(string)
  default     = []
  description = "ARNs of AWS entities who can access the repository"
}
variable "lifecycle_policy" {
  type    = string
  default = ""
}
variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "IMMUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Must be either `MUTABLE` or `IMMUTABLE`."
  }
}
