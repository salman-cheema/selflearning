# Pre Req
# S3 Bucket and DynamoDb needs to be create first manually before initializing terraform

# terraform {
#   backend "s3" {
#     bucket = "<setaname-terraform-sandbox-states>"
#     key    = "selflearning/terraform.tfstate"
#     region = "us-east-1"
# # This setting will be used if multiple people are working on the terraofmr code.
#     #    dynamodb_table = "selflearning-terraform-locks"
#     #    encrypt        = true
#   }
# }
