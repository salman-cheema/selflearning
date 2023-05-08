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
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.19.0"
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