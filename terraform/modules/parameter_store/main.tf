resource "aws_ssm_parameter" "parameters" {
  name      = var.name
  type      = var.type
  value     = var.value
  key_id    = var.key_id == null ? "" : var.key_id
  tags      = var.tags
  overwrite = var.overwrite
}
