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

data "terraform_remote_state" "rates_api_app" {
  backend   = "s3"
  workspace = local.env
  config = {
    bucket = "insurify-terraform-sandbox-states"
    region = "us-east-1"
    key    = "insurify2//terraform.tfstate"
  }
}