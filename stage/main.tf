# provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# backend
terraform {
  backend "s3" {
    bucket = "tf-raisetech-lec10cfn"
    key    = "tf-raisetech-lec10cfn/stage/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# moduleの利用
module "aws-modules" {
  # moduleの位置
  source = "../modules"
}
