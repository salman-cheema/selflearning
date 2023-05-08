resource "aws_iam_policy" "selflearning_rate_batch_jobs_ecs_ecr_access" {
  name   = "selflearningRatesBatchJobsECSECRAccess${local.env}"
  policy = data.aws_iam_policy_document.selflearning_rate_batch_jobs_ecs_ecr_access.json
}

data "aws_iam_policy_document" "selflearning_rate_batch_jobs_ecs_ecr_access" {
  statement {
    sid    = "selflearningECSECRAccess"
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = [module.ecr_rates_batch_jobs.repository_arn]
  }
  statement {
    sid    = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AccessToS3RatesBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.bucket_selflearning_rates.s3_bucket_arn]
  }

  statement {
    sid    = "AccessToS3RatesFiles"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = ["${module.bucket_selflearning_rates.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "run_ecs_batch_jobs_access_for_lambda" {
  name        = "AccessToECSTask${local.env}"
  description = "Access to resources necessary to run and list ECS tasks"
  policy      = data.aws_iam_policy_document.run_ecs_batch_jobs_access_for_lambda.json
}

data "aws_iam_policy_document" "run_ecs_batch_jobs_access_for_lambda" {
  statement {
    sid    = "AccessToECSTask"
    effect = "Allow"
    actions = [
      "ecs:RunTask",
      "ecs:ListTasks",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AccessECSTask"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [module.rates_batch_jobs_task_definition_role.iam_role_arn]
  }
}