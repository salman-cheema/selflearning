locals {
  default_tags = {
    Terraform   = "true"
    Environment = local.env
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

#   assume_role {
#     role_arn = "arn:aws:iam::${var.aws_account_id}:role/selflearningTerraformDeployment"
#   }

}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  env                 = terraform.workspace
  aws_region          = data.aws_region.current.name
  aws_accountId       = data.aws_caller_identity.current.account_id
}

data "terraform_remote_state" "rates_api_app" {
  backend   = "s3"
  workspace = local.env
  config = {
    bucket = "insurify-terraform-sandbox-states"
    region = "us-east-1"
    key    = "insurify2//terraform.tfstate"
  }
}