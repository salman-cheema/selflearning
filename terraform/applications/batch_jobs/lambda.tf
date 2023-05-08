locals {
  run_ecs_batch_jobs_task_lambda_filename = "run_ecs_batch_jobs_task_lambda"
}

data "archive_file" "run_ecs_batch_jobs_task_lambda_as_archive" {
  type        = "zip"
  source_file = "${path.module}/files/run_ecs_batch_jobs_task/${local.run_ecs_batch_jobs_task_lambda_filename}.py"
  output_path = "${local.run_ecs_batch_jobs_task_lambda_filename}.zip"
}

resource "aws_lambda_function" "run_ecs_batch_jobs_task" {
  count            = can(data.terraform_remote_state.rates_api_app.outputs.vpc_id) ? 1 : 0
  function_name    = "run-ecs-task-batch-jobs-lambda"
  role             = module.run_ecs_batch_jobs_task.iam_role_arn
  filename         = "${local.run_ecs_batch_jobs_task_lambda_filename}.zip"
  source_code_hash = data.archive_file.run_ecs_batch_jobs_task_lambda_as_archive.output_base64sha256
  handler          = "${local.run_ecs_batch_jobs_task_lambda_filename}.handler"
  runtime          = "python3.9"
  timeout          = 15

  environment {
    variables = {
      sg_for_ecs_task                 = jsonencode([module.sg_rates_batch_job_ecs_task[0].security_group_id])
      subnets_for_ecs_task            = jsonencode(data.terraform_remote_state.rates_api_app.outputs.private_subnets)
      cluster_name_for_ecs_task       = module.ecs_rates_batch_jobs_cluster.cluster_name
      execution_role_arn_for_ecs_task = module.rates_batch_jobs_task_definition_role.iam_role_arn
      task_role_arn_for_ecs_task      = module.rates_batch_jobs_task_definition_role.iam_role_arn
      task_definition_family_name     = local.rates_batch_job_name
    }
  }
  vpc_config {
    subnet_ids         = data.terraform_remote_state.rates_api_app.outputs.private_subnets
    security_group_ids = [module.sg_run_ecs_batch_job_lambda[0].security_group_id]
  }
}

resource "aws_lambda_permission" "run_ecs_batch_jobs_task" {
  count            = can(data.terraform_remote_state.rates_api_app.outputs.vpc_id) ? 1 : 0
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.run_ecs_batch_jobs_task[0].arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.bucket_selflearning_rates.s3_bucket_arn
}
