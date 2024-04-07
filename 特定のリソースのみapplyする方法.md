# 背景・目的
EC2とそれに関連するVPC、サブネット、セキュリティグループを必要最低限でさくっと構築、さくっと削除したい

# 前提
- フォルダ構成は以下の通り
```
C:.
|   .terraform-version
+---modules
|       01-vpc.tf
|       02-sg.tf
|       03-ec2.tf
|       04-rds.tf
|       05-alb.tf
|       06-s3.tf
|       variables.tf
|
\---stage
    |   .terraform.lock.hcl
    |   main.tf
    |   terraform.tfvars
    |   variables.tf
    |
    \---.terraform
        |   terraform.tfstate
        |
        +---modules
        |       modules.json
        |
        \---providers
            \---registry.terraform.io
                \---hashicorp
                    \---aws
                        \---3.76.1
                            \---windows_amd64
                                    terraform-provider-aws_v3.76.1_x5.exe
```
- terraform実行コマンドはstageディレクトリ(実行環境ディレクトリ)で実行する構成

# 結論
```bash
$ terraform plan|apply|destroy \
-target=module.aws-modules.aws_instance.ec2_tf \
-target=module.aws-modules.aws_internet_gateway.gw \
-target=module.aws-modules.aws_route_table.public_rt \
-target=module.aws-modules.aws_route_table_association.public1c_rt_associate
```
- `terraform plan|apply|destroy`：用途に合わせていずれかつかう
- `target=module.aws-modules.aws_instance.ec2_tf`：インスタンスだけほしいなら基本これでいけるはずだが、、
- 依存関係をきっちりterraformが拾ってくれなかったら以下のリソースについても明示的にapplyなどする

# 実施内容
- `terraform plan|apply|destroy| -target=module.モジュール名.リソースタイプ.リソース名`である程度可能
- 今回の環境では以下の通り。
  - `aws-modules`はmain.tfに記述しています
  - `aws_instance`と`ec2_tf`は03-ec2.tfに記述しています
```bash
$ terraform plan -target=module.aws-modules.aws_instance.ec2_tf
```
依存関係はある程度terraformがいい具合にひろって構築してるようです。結果は以下の通りです。
<details><summary>実行結果</summary>

```bash
$ terraform plan -target=module.aws-modules.aws_instance.ec2_tf
module.aws-modules.data.aws_ami.amzlinux2: Reading...
module.aws-modules.data.aws_ami.amzlinux2: Read complete after 0s [id=ami-0b083c14714c26021]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.aws-modules.aws_instance.ec2_tf will be created
  + resource "aws_instance" "ec2_tf" {
      + ami                                  = "ami-0b083c14714c26021"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "Kawasaki1002"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "20240407-terraform-stage"
        }
      + tags_all                             = {
          + "Name" = "20240407-terraform-stage"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)
    }

  # module.aws-modules.aws_security_group.sg_ec2 will be created
  + resource "aws_security_group" "sg_ec2" {
      + arn                    = (known after apply)
      + description            = "sg_ec2"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + name                   = "sg_ec2"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "20240407-terraform-stage"
        }
      + tags_all               = {
          + "Name" = "20240407-terraform-stage"
        }
      + vpc_id                 = (known after apply)
    }

  # module.aws-modules.aws_subnet.public_1c_sn will be created
  + resource "aws_subnet" "public_1c_sn" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "ap-northeast-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "20240407-terraform-stage"
        }
      + tags_all                                       = {
          + "Name" = "20240407-terraform-stage"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.aws-modules.aws_vpc.main_vpc will be created
  + resource "aws_vpc" "main_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_classiclink                   = (known after apply)
      + enable_classiclink_dns_support       = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "20240407-terraform-stage"
        }
      + tags_all                             = {
          + "Name" = "20240407-terraform-stage"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as     
│ part of an error message.
╵
╷
│ Warning: Argument is deprecated
│
│   with module.aws-modules.aws_s3_bucket.s3-alb-log240407tf,
│   on ..\modules\06-s3.tf line 29, in resource "aws_s3_bucket" "s3-alb-log240407tf":
│   29: resource "aws_s3_bucket" "s3-alb-log240407tf" {
│
│ Use the aws_s3_bucket_lifecycle_configuration resource instead
```
</details>
<br>

実行結果を見る感じ、インターネットゲートウェイがアタッチされてないなどあったので、詳しく見てみると以下のリソースについては構築されていませんでした。案の定EC2へssh接続不可でした。
- インターネットゲートウェイ
- ルートテーブル
- ルートテーブルとサブネットとの関連付け

なので、以下を追加で実行しました。
```bash
$ terraform apply \
-target=module.aws-modules.aws_internet_gateway.gw \
-target=module.aws-modules.aws_route_table.public_rt \
-target=module.aws-modules.aws_route_table_association.public1c_rt_associate
```


参考）
- 公式：https://developer.hashicorp.com/terraform/cli/commands/plan#target-address
- 公式：https://developer.hashicorp.com/terraform/cli/state/resource-addressing

# まとめ
- 手軽にLinux環境用意したい、EC2使いたいなどの時は楽です。1分くらいで出来上がります。
- ただし、terraformが完全に依存関係をひろってくれているかはわからないので、実行結果や`terraform show`で管理リソースを確認した方がいいと思いました。
- `terraform plan -target=aws_instance.ec2_tf`ではうまく行きませんでした。

