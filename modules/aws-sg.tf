
############
# リソース定義
############
# EC2（APサーバ）用のsg：SSH接続可とHTTP(80ポート)
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "sg_ec2"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-stage"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ALB用のsg：HTTP(80ポート)
resource "aws_security_group" "sg_alb" {
  name        = "sg_alb"
  description = "sg_alb"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-stage"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS用のsg：MySQL用の3306
resource "aws_security_group" "sg_rds" {
  name        = "sg_rds"
  description = "sg_rds"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-stage"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############
# Output定義
############

output "sg_ec2_id" {
  value = aws_security_group.sg_ec2.id
}
output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}
output "sg_rds_id" {
  value = aws_security_group.sg_rds.id
}

