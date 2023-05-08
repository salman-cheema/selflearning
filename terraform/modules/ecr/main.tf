module "ecr" {
  source                            = "terraform-aws-modules/ecr/aws"
  version                           = "1.4.0"
  repository_name                   = var.name
  repository_read_write_access_arns = var.read_write_access_arns
  repository_lifecycle_policy       = var.lifecycle_policy
  tags                              = var.tags
  repository_image_tag_mutability   = var.image_tag_mutability
}
