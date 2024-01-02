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
module "aws-vpc" {
    # moduleの位置
    source = "../modules"
    # 変数の定義
    my_cidr_block = "10.0.0.0/16"
    my_env        = "stage"
    az_a    = "ap-northeast-1a"
    az_c    = "ap-northeast-1c"

}