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
  region = var.region
}

# backend
## terraformブロックの中では変数をつかえないのでregionはハードコードです
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
  #=========================
  # 環境ごとの変数定義（今回はstageとして）
  #=========================
  # タグ定義
  my_env      = "stage"
  create_by   = "terraform"
  create_date = "20240105"
  # ネットワーク定義
  myvpc_cidr_block = "10.0.0.0/16"
  # EC2定義
  ec2key_name      = "Kawasaki1002"
  ec2instance_type = "t2.micro"
  # DB定義
  ## mysqlのusernameは"admin"と書いてもいいですが、今回はtfvarsに大事な情報を変数として入れ、tfvarsのみ公開しない（.gitignore）と仮定してこの記述としました
  mysqlusername    = var.mysqlusername
  dbengine         = "mysql"
  dbengine_version = "8.0.33"
  dbinstance_class = "db.t3.micro"
}
