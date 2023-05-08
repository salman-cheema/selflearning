
module "bucket_selflearning_rates" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.6.0"
  bucket        = "${local.env}-selflearning-rates"
  force_destroy = true
  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  object_ownership         = "BucketOwnerEnforced"
  control_object_ownership = true
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
}

# This notofication needs to be create if we create Lambda
resource "aws_s3_bucket_notification" "run_ecs_batch_jobs_task" {
  count            = can(data.terraform_remote_state.rates_api_app.outputs.vpc_id) ? 1 : 0
  bucket = module.bucket_selflearning_rates.s3_bucket_id
  lambda_function {
    lambda_function_arn = aws_lambda_function.run_ecs_batch_jobs_task[0].arn
    events = [
      "s3:ObjectCreated:Put",
      "s3:ObjectCreated:Post"
    ]
  }
}