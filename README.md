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




## 結果
コーディングや結果は以下の通りです。
|.tfファイル|結果|トライアンドエラー|
|:---|:---|:---|
|[main.tf](stage/main.tf)|[result_vpc.tf.md](result_vpc.tf.md)|[TryandError01_変数定義の記述場所.md](TryandError01_変数定義の記述場所.md)|
|[aws-vpc.tf](modules/aws-vpc.tf)|[result_vpc.tf.md](result_vpc.tf.md)|-|