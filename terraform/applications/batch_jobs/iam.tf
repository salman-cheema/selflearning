module "rates_batch_jobs_task_definition_role" {
  source                  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version                 = "4.1.0"
  role_name             = "selflearningECSTaskDefinitionBatchJobsRole${local.env}"
  create_role             = true
  role_requires_mfa     = false
  trusted_role_services = ["ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    aws_iam_policy.selflearning_rate_batch_jobs_ecs_ecr_access.arn
  ]
}

resource "aws_iam_policy" "selflearning_rate_batch_jobs_ecs_ecr_access" {
  name   = "selflearningRatesBatchJobsECSECRAccess${local.env}"
  policy = data.aws_iam_policy_document.selflearning_rate_batch_jobs_ecs_ecr_access.json
}