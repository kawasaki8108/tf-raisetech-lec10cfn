#最新のAMIを取得する
data "aws_ami" "amzlinux2" {
  #最新版を取得
  most_recent = true
  owners      = ["amazon"]
  #AMIのタイプamzn2-ami-hvm-*、architecturex86_64、ブロックストレージボリュームタイプgp2でfilter検索
  filter { #
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "ec2_tf" {
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = "t2.micro"
  key_name               = "Kawasaki1002"
  #インスタンスをパブリックIPアドレスに関連付けるか（ブール値）
  associate_public_ip_address = true
  subnet_id              = aws_subnet.public_1c_sn.id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  #terraform applyの時に最新版としてAMIを更新しないようにlifecycleを設定
  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
  tags = {
    Name = "terraform-stage"
  }

}

############
# Output定義
############

output "ec2_public_ip" {
  value = aws_instance.ec2_tf.public_ip
}
output "ec2_public_dns" {
  value = aws_instance.ec2_tf.public_dns
}
output "ec2_instance_id" {
  value = aws_instance.ec2_tf.id
}

