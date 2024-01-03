# CloudFormationで構築した環境をTerraformで構築する
## 方針
* Modules機能をつかって構築することにしました。
* 環境ごとの差異が多い場合などに活用するそうですが、直感的にわかりやすいなと思ったのでworkspace機能ではなくこちらにしました。
* 各リソースがモジュールとして分離されているので、疎結合を保ったまま構築ができ、たとえば実際の開発現場で、モジュールごとに開発することがあれば便利かと思います。
## フォルダ構成と空ファイルを用意
* **ゴール**：以下の形を作ります
* この構成の場合、「terraform.tfvars」ファイルを用意していてもうまく読めなかったので、変数定義はmain.tfに記述することにしました
```bash
\---tf-raisetech-lec10cfn
    |   .terraform-version
    |   README.md
    |
    +---modules
    |       aws-alb.tf
    |       aws-ec2.tf
    |       aws-rds.tf
    |       aws-s3.tf
    |       aws-sg.tf
    |       aws-vpc.tf
    |
    \---stage
            main.tf
```

* ユーザー名のディレクトリの下に以下の通りディレクトリ作成(今後も別の要件で使うかもしれないのでフォルダ整理のために)
```bash
$ mkdir ~/TerraformPJ/
```
* 「TerraformPJ」の下に各種PJをフォルダわけしようと思います
* 今回のテストランはGithubにあげようと思うので、先にGitHubでリモートリポジトリを作成してローカルにgit cloneすることろからやりました
```bash
$ git clone https://github.com/username/tf-raisetech-lec10cfn.git
$ cd tf-raisetech-lec10cfn
$ mkdir modules && cd $_
$ touch aws-vpc.tf aws-sg.tf aws-ec2.tf aws-rds.tf aws-alb.tf aws-s3.tf
$ mkdir ../stage
$ cd ../stage
$ touch main.tf
$ cd ../
$ pwd
/c/Users/username/TerraformPJ/tf-raisetech-lec10cfn
$ tfenv pin #当該ディレクトリではこのバージョンで使うことを指定
Pinned version by writing "1.6.6" to /c/Users/username/TerraformPJ/tf-raisetech-lec10cfn/.terraform-version
$ ls -al | grep .terra
$ cat .terraform-version
1.6.6
$ cd ../
$ pwd
/c/Users/username/TerraformPJ
$ tree      #ゴールに記載したフォルダ構成になっているはず
```

## Backend機能を使う
先に以下のコマンドでS3バケットを生成しておく
```bash
$ aws s3 mb s3://tf-raisetech-lec10cfn
make_bucket: tf-raisetech-lec10cfn
```


## 結果
コーディングや結果は下表の通りです。
* main.tfは[stage](stage)フォルダにあります
* 各リソースごとの.tfファイルは[modules](modules)フォルダにあります
* 「結果」はマネジメントコンソール画面のキャプチャを撮りためているので、それを上げる予定です
* 「トランアンドエラー」もキャプチャをとりためているので、それを挙げていく予定です
<br>

|.tfファイル|結果|トライアンドエラー|
|:---|:---|:---|
|[main.tf](stage/main.tf)|-|[TryandError01_変数定義の記述場所.md](TryandError01_変数定義の記述場所.md)|
|[01-vpc.tf](modules/01-vpc.tf)|[result_vpc.tf.md](result_vpc.tf.md)|-|
|[02-sg.tf](modules/02-sg.tf)|[]()|[]()|
|[03-ec2.tf](modules/03-ec2.tf)|[]()|[]()|
|[04-rds.tf](modules/04-rds.tf)|[]()|[]()|
|[05-alb.tf](modules/05-alb.tf)|[]()|[]()|
|[06-s3.tf](modules/06-s3.tf)|[]()|[]()|


いろいろ参考にして実装しました。以下の通りです。

## main.tfを編集
stageのディレクトリで`terraform init`してから以下の順に操作
```bash
$ terraform fmt
$ terraform validate    #計10回はトライアンドエラーしていました。。
$ terraform apply
```


## vpc.tfを編集
### 参考記事
* [【Terraform入門】AWSのVPCとEC2を構築してみる](https://kacfg.com/terraform-vpc-ec2/)
* 公式doc
  * https://kacfg.com/terraform-vpc-ec2/
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway_attachment
  * 
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
    * Routeととしてのresource記載は不要で、RouteTableのresource内部にrouteの内容を記述できる
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

## sg.tfを編集
### 参考記事
* https://dev.classmethod.jp/articles/terraform-security-group/
* https://beyondjapan.com/blog/2022/10/terraform-how-to-use-security-group/
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
    * 特にRDS用のセキュリティグループのインバウンドルールにおけるソースをEC2用のセキュリティグループIDにするという方法の参照として使いました。↓の参考記事も同様です。
* https://ohshige.hatenablog.com/entry/2019/11/11/190000
* https://qiita.com/suzuki0430/items/2dbd88dfb5ed53016914

## ec2.tfを編集
### 参考記事
* https://zenn.dev/supersatton/articles/c87853cc5a3dbd
* https://qiita.com/okdyy75/items/73641a0247bae1fa7f31
* https://khasegawa.hatenablog.com/entry/2017/10/03/000000
* [[Terraform][CloudFormation]最新のAMI IDの取得方法](https://qiita.com/to-fmak/items/7623ee6e15249a4bcedd#:~:text=%E3%80%8CData%20Source%E3%80%8D%E3%81%A7%E6%9C%80%E6%96%B0%E3%81%AE,AMI%E3%82%92%E5%8F%96%E5%BE%97%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%99%E3%80%82)
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance

## rds.tfを編集
### 参考記事
* https://zenn.dev/suganuma/articles/fe14451aeda28f
* https://tech.isid.co.jp/entry/terraform_manage_master_user_password
* https://zenn.dev/yumemi_inc/articles/081b0190db8260
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
