locals {
  target_group_arns = {
    for index, name in module.rates_api_alb.target_group_names : name => module.rates_api_alb.target_group_arns[index]
  }

  rates_api_target_groups = [
    {
      name              = "${local.env}-rates-api-tg"
      backend_port      = 3000
      health_check_path = "/healthy"
      target_type       = "ip"
      targets           = {}
      tags = {
        Name = "${local.env}-rates-api-tg"
      }
    }
  ]
  ## create list of map for target groups
  target_groups = flatten([
    for target_group in local.rates_api_target_groups : [
      {
        name                 = lookup(target_group, "name")
        deregistration_delay = lookup(target_group, "deregistration_delay", 300)
        backend_protocol     = lookup(target_group, "backend_protocol", "HTTP")
        target_type          = lookup(target_group, "target_type", "instance")
        backend_port         = lookup(target_group, "backend_port")
        targets              = lookup(target_group, "targets", {})
        health_check = length(lookup(target_group, "health_check", {})) != 0 ? lookup(target_group, "health_check") : {
          enabled             = true
          interval            = 30
          path                = lookup(target_group, "health_check_path")
          port                = "traffic-port"
          healthy_threshold   = 5
          unhealthy_threshold = 2
          timeout             = 5
          protocol            = "HTTP"
          matcher             = "200"
        }
        stickiness = {
          enabled         = lookup(target_group, "stickiness", false)
          cookie_duration = 3600
          type            = "lb_cookie"
        }
        tags = lookup(target_group, "tags", {})
    }]
  ])
}


module "rates_api_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.2.1"
  name    = "${local.env}-rates-api-alb"
  vpc_id  = module.vpc.vpc_id
  #subnets                      = var.subnets
  subnets = module.vpc.public_subnets
  # subnets = ["subnet-03b40e83a333a5be6", "subnet-0af7fd670665bc2be"]
  security_groups = [module.sg_rates_api_alb.security_group_id]
  target_groups   = local.target_groups
  # In real application we use https_listener_rules but due to limitaiton of ACM and domains we are eliminating it here
  #  https_listener_rules         = local.https_listener_rules

  # In real application we make it re-direct to https
  # Due to limitaiton of ACM/domains we will forward traffic to our targets
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

output "rates_api_alb_dns" {
  value = module.rates_api_alb.lb_dns_name
}