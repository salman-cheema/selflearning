# Pre Req
# S3 Bucket and DynamoDb needs to be create first manually before initializing terraform

terraform {
  backend "s3" {
    bucket         = "insurify-terraform-sandbox-states"
    key            = "insurify-batch/terraform.tfstate"
    region         = "us-east-1"
#    dynamodb_table = "insurify-terraform-locks"
#    encrypt        = true
  }
}
