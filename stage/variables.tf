# main.tf内で記述する変数についての定義をする
# 各moduleの.tfファイル内に登場する変数はmodulesフォルダ内の「variables.tf」ファイルに記述する

variable "region" {
  # default = "ap-northeast-1"
  description = "AWS region"
}

variable "mysqlusername" {}