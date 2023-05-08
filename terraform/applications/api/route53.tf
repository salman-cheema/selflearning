resource "aws_route53_zone" "internal_selflearning" {
  name = "selflearning.internal"

  vpc {
    vpc_id = module.vpc.vpc_id
  # vpc_id      = "vpc-0aca9d355c9807d68"
  }
  lifecycle {
    ignore_changes = [vpc]
  }
}