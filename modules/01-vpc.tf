
############
# リソース定義
############
# ----------
# VPC
# ----------
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.myvpc_cidr_block
  enable_dns_support   = true #Public DNSを割り当てるため
  enable_dns_hostnames = true #Public DNSを割り当てるため

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}" 
  }
}

# ---------------------------
# Subnet
# ---------------------------
# PublicSubnet1a
resource "aws_subnet" "public_1a_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }
}

# PublicSubnet1c
resource "aws_subnet" "public_1c_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_c

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }
}

# PrivateSubnet1a
resource "aws_subnet" "private_1a_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}-private-1a-sn"
  }
}

# PrivateSubnet1c
resource "aws_subnet" "private_1c_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az_c

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}-private-1c-sn"
  }
}

# ----------
# IGW
# ----------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }
}

#IGWAttachmentを入れようとすると↓
#「The provider hashicorp/aws does not support resource type "aws_internet_gateway_attachment".」
#と言われたので消しました↓
# # ----------
# # IGWAttachment
# # ----------
# resource "aws_internet_gateway_attachment" "gw_att" {
#   internet_gateway_id = aws_internet_gateway.gw.id
#   vpc_id = aws_vpc.main_vpc.id
# }

# ---------------------------
# Route table
# ---------------------------
# Route table作成
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }
}

# PublicSubnet1aとRoute tableの関連付け
resource "aws_route_table_association" "public1a_rt_associate" {
  subnet_id      = aws_subnet.public_1a_sn.id
  route_table_id = aws_route_table.public_rt.id
}

# PublicSubnet1cとRoute tableの関連付け
resource "aws_route_table_association" "public1c_rt_associate" {
  subnet_id      = aws_subnet.public_1c_sn.id
  route_table_id = aws_route_table.public_rt.id
}


############
# Output定義
############
# ターミナルへの出力・他ファイルからの参照
# 同じファイル内なら、VPC IDは「aws_vpc.main_vpc.id」で参照ができる
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}
output "public1a_id" {
  value = aws_subnet.public_1a_sn.id
}
output "public1c_id" {
  value = aws_subnet.public_1c_sn.id
}
output "private1a_id" {
  value = aws_subnet.private_1a_sn.id
}
output "private1c_id" {
  value = aws_subnet.private_1c_sn.id
}