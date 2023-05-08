module "rates_batch_jobs_task_definition_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version               = "4.1.0"
  role_name             = "selflearningECSTaskDefinitionBatchJobsRole${local.env}"
  create_role           = true
  role_requires_mfa     = false
  trusted_role_services = ["ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    aws_iam_policy.selflearning_rate_batch_jobs_ecs_ecr_access.arn
  ]
}

module "run_ecs_batch_jobs_task" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version               = "4.1.0"
  role_name             = "${local.env}-selflearningECSGithubRunnersLambda"
  create_role           = true
  role_requires_mfa     = false
  trusted_role_actions  = ["sts:AssumeRole"]
  trusted_role_services = ["lambda.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.run_ecs_batch_jobs_access_for_lambda.arn
  ]
}

