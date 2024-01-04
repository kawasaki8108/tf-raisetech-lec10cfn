############
# データ取得の定義
############
#System ManegerのParameter Storeに保管しているPWを取得する
#予めSystem ManegerのParameter Storeで作成しておかないといけないのが完全なIaCではないのが痛い
#ParameterStoreは無料で使えるがSecretManagerは有料なのでParameterStoreにした
#現場で書くなら変数扱いにしたほうがいいと思います
data "aws_ssm_parameter" "ssm_paramstr_pw_tf" {
  name            = "RDSMasterPassword"
  with_decryption = true
}


############
# リソース定義
############
#DBSubnetGroup作成（RDSを入れるvpcを指定するため）
resource "aws_db_subnet_group" "dbsng_tf" {
  name       = "dbsng_tf"
  subnet_ids = [aws_subnet.private_1a_sn.id, aws_subnet.private_1c_sn.id]

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }
}

#DBインスタンスRDS作成
resource "aws_db_instance" "rds_tf" {
  allocated_storage = 10
  #↓「An argument named "db_name" is not expected here.」と言われたのでコメントアウト
  # db_name           = "mydb"
  engine            = var.dbengine
  engine_version    = var.dbengine_version
  instance_class    = var.dbinstance_class
  #mysqlのusernameは"admin"と書いてもいいですが、今回はtfvarsに大事な情報を変数として入れ、tfvarsのみ公開しない（.gitignore）と仮定してこの記述としました
  username          = var.mysqlusername
  availability_zone = var.az_c
  multi_az          = false
  #dataで取得した値を入れる
  password            = data.aws_ssm_parameter.ssm_paramstr_pw_tf.value
  skip_final_snapshot = true
  #上で作成したsubnet_groupを入れ、適用するvpcを指定する
  db_subnet_group_name   = aws_db_subnet_group.dbsng_tf.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }
}

############
# Output定義
############
output "dbsng_tf" {
  value = aws_db_subnet_group.dbsng_tf.id
}

output "db-entpoint" {
  value = aws_db_instance.rds_tf.endpoint
}
