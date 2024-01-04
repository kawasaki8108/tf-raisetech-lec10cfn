#タグ情報==================
#完成例：20240105-terraform-stage
variable "create_date" {
  description = "create_date tag"
}
variable "create_by" {
  default     = "terraform"
  description = "create_by tag"
}
variable "my_env" {
  default     = "prod"
  description = "enviroment tag"
}
#=========================

#=========================
# ネットワーク関連の変数定義
#=========================
#vpcのサイダーブロックはmain.tfで指定する
variable "myvpc_cidr_block" {}
variable "az_a" {
  default     = "ap-northeast-1a"
  description = "availability_zone_a"
}
variable "az_c" {
  default     = "ap-northeast-1c"
  description = "availability_zone_c"
}
#=========================
# EC2関連の変数定義
#=========================
variable "ec2key_name" {}
variable "ec2instance_type" {
  default = "t2.micro"
  #現場での運用を想像して説明文いれてみました
  description = "Please use the free version exept production env(i.e. t2.micro)."
}


#=========================
# RDS関連の変数定義
#=========================
variable "dbengine" {}
variable "dbengine_version" {}
variable "dbinstance_class" {
  default = "db.t3.micro"
  #現場での運用を想像して説明文いれてみました
  description = "Please use the free version exept production env(i.e. db.t3.micro)."
}
variable "mysqlusername" {}