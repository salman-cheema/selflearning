data "aws_iam_policy_document" "selflearning_rate_api_ecs_ecr_access" {
  statement {
    sid    = "selflearningECSECRAccess"
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = [module.ecr_rates_api.repository_arn]
  }
  statement {
    sid    = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}