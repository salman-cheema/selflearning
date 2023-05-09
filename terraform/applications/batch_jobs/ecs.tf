locals {
  cluster_name = "${local.env}-selflearning-rates-batch-jobs"
  rates_batch_job_container_name = "${local.env}_rates_batch_jobs"
}

module "ecs_rates_batch_jobs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "4.1.2"
  cluster_name = local.cluster_name
  tags         = local.default_tags
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_clsuter_rates_batch_jobs.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_clsuter_rates_batch_jobs" {
  name              = "ecs/${local.env}/rates_batch_jobs"
  retention_in_days = 90
  tags              = local.default_tags
}

resource "aws_cloudwatch_log_group" "ecs_task_rates_batch_jobs" {
  name              = "ecs/${local.env}/task/rates_batch_jobs"
  retention_in_days = 90
}
module "ecs_rates_batch_jobs_container_definition" {
  count           = can(data.terraform_remote_state.rates_api_app.outputs.rds_endpoint) ? 1 : 0
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "0.58.1"
  container_name  = local.rates_batch_job_container_name
  container_image = var.rate_api_image_to_deploy == "" ? "${module.ecr_rates_batch_jobs.repository_url}:${local.rates_batch_jobs_tag_sha}" :  "${module.ecr_rates_batch_jobs.repository_url}:${var.rate_api_image_to_deploy}"
  readonly_root_filesystem = false
  environment = [
    {
      name  = "DB_NAME"
      value = try(data.terraform_remote_state.rates_api_app.outputs.rates_api_db_name, "")
    },
    {
      name  = "DB_USER"
      value = try(data.terraform_remote_state.rates_api_app.outputs.rates_api_username, "")
    },
    {
      name  = "DB_HOST"
      value = try(data.terraform_remote_state.rates_api_app.outputs.rds_endpoint, "")
    },
    { name  = "RATES_RW_PASSWORD"
      value = try(data.terraform_remote_state.rates_api_app.outputs.rates_rds_password, "")
    }
  ]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.ecs_task_rates_batch_jobs.name
      awslogs-region        = local.aws_region
      awslogs-stream-prefix = "ecs"
    }
  }
}
resource "aws_ecs_task_definition" "task_def_rates_batch_jobs" {
  count           = can(data.terraform_remote_state.rates_api_app.outputs.rds_endpoint) ? 1 : 0
  family                   = "${local.env}-rates_batch_jobs"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.rates_batch_jobs_task_definition_role.iam_role_arn
  task_role_arn            = module.rates_batch_jobs_task_definition_role.iam_role_arn
  network_mode             = "awsvpc"
  cpu             = 1024
  memory             = 2048
  container_definitions    = module.ecs_rates_batch_jobs_container_definition[0].json_map_encoded_list
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}