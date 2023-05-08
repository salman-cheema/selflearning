locals {
  cluster_name = "${local.env}-selflearning-rates-api"
  rates_api_container_name = "${local.env}_rates_api"
}
module "ecs_rates_api_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "4.1.2"
  cluster_name = local.cluster_name
  tags         = local.default_tags
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_clsuter_api.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_clsuter_api" {
  name              = "ecs/${local.env}/rates_api"
  retention_in_days = 90
  tags              = local.default_tags
}

resource "aws_cloudwatch_log_group" "ecs_task_rates_api" {
  name              = "ecs/${local.env}/task/rates_api"
  retention_in_days = 90
}
module "ecs_rates_api_container_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "0.58.1"
  container_name  = local.rates_api_container_name
  container_image = var.rate_api_image_to_deploy == "" ? "${module.ecr_rates_api.repository_url}:${local.rates_api_tag_sha}" : "${module.ecr_rates_api.repository_url}:${var.rate_api_image_to_deploy}"
  readonly_root_filesystem = false
  port_mappings = [{
    containerPort = 3000
    hostPort      = 3000
    protocol      = "tcp"
  }]
  environment = [
    {
      name  = "DB_NAME"
      value = local.rates_api_db_name
    },
    {
      name  = "DB_USER"
      value = local.rates_api_username
    },
    {
      name  = "DB_HOST"
      value = module.rds_endpoint.value
    },
    { name  = "PASSWORD"
      value = module.rates_rds_password.value
    }
  ]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.ecs_task_rates_api.name
      awslogs-region        = local.aws_region
      awslogs-stream-prefix = "ecs"
    }
  }
}
resource "aws_ecs_task_definition" "rates_api" {
  family                   = "${local.env}-rates_pai"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.rates_api_task_definition_role.iam_role_arn
  task_role_arn            = module.rates_api_task_definition_role.iam_role_arn
  network_mode             = "awsvpc"
  cpu             = 1024
  memory             = 2048
  container_definitions    = module.ecs_rates_api_container_definition.json_map_encoded_list
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "rates_api" {
  name                               = "${local.env}-rates-api"
  cluster                            = module.ecs_rates_api_cluster.cluster_id
  task_definition                    = aws_ecs_task_definition.rates_api.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 300
  launch_type                        = "FARGATE"
  load_balancer {
    target_group_arn = local.target_group_arns["${local.env}-rates-api-tg"]
    container_name   = local.rates_api_container_name
    container_port   = "3000"
  }

    network_configuration {
    security_groups = [module.sg_rates_api.security_group_id]
    subnets         = module.vpc.private_subnets
# subnets = ["subnet-0b9511dda4776a9ec", "subnet-0ca28b496d022545b"]
  }
    lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [module.rates_api_alb, null_resource.rates_api_provisioner]
}

resource "aws_appautoscaling_target" "rates_api" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${local.cluster_name}/${aws_ecs_service.rates_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "rates_api" {
  name               = "${local.env}-rates-api-cpu-auto-scaling"
  service_namespace  = aws_appautoscaling_target.rates_api.service_namespace
  scalable_dimension = aws_appautoscaling_target.rates_api.scalable_dimension
  resource_id        = aws_appautoscaling_target.rates_api.resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 3
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
