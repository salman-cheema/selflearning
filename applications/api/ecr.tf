module "ecr_rates_api" {
  source = "../../modules/ecr"
  name   = "${local.env}-rates-api"
  tags   = local.default_tags
  read_write_access_arns = [
    module.rates_api_task_definition_role.iam_role_arn
  ]
  image_tag_mutability = "MUTABLE"
  lifecycle_policy = jsonencode({
    rules = [
      {
        "rulePriority" : 1,
        "description" : "Keep only one untagged image, expire all others",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "imageCountMoreThan",
          "countNumber" : 1
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}