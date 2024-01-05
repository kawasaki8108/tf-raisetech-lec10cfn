# CloudFormationで構築した環境をTerraformで構築する
## 方針
* Modules機能をつかって構築することにしました。
* 環境ごとの差異が多い場合などに活用するそうですが、直感的にわかりやすいなと思ったのでworkspace機能ではなくこちらにしました。
* 各リソースがモジュールとして分離されているので、疎結合を保ったまま構築ができ、たとえば実際の開発現場で、モジュールごとに開発することがあれば便利かと思います。
* 今回作成するインフラストラクチャは[こちらの構成図（VPC,EC2,RDS,ALB,S3）](https://github.com/kawasaki8108/RaiseTech/blob/main/image_05/RiaseTech-lecture05%E6%A7%8B%E6%88%90%E5%9B%B3.png)です
* DynamoDB を使って、排他ロック（先に操作した人が終わるまで apply などをブロックする）をかけるという方法もありますが今回は割愛します。
  * https://www.terraform.io/docs/backends/types/s3.html#dynamodb-state-locking
* 今回作成するフォルダ構成は次の通りです。

## フォルダ構成
* .terraformフォルダ以下はstageディレクトリで`terraform init`で自動で生成されます
* terraform.tfvarsファイル使わなくてもmain.tfに変数定義を記述してもいいのですが、今回はtfvarsの使い方を理解するために使用しました。
```bash
\---tf-raisetech-lec10cfn
    |   .terraform-version        #バージョン指定
    |
    +---modules
    |       01-vpc.tf
    |       02-sg.tf
    |       03-ec2.tf
    |       04-rds.tf
    |       05-alb.tf
    |       06-s3.tf
    |       variables.tf          #modules下のリソースファイル.tfで使う変数の中身を記述する
    |
    \---stage
        |   .terraform.lock.hcl   #`terraform init`で自動で生成される
        |   main.tf               #中身：provider,terraform,baskend,modulesのブロック＋各moduleで使う変数の中身を"stage環境としては”で記述する
        |   terraform.tfvars      #stageディレクトリ下での変数定義を入れる
        |   variables.tf          #stageディレクトリ下での変数名を設定する
        |
        \---.terraform            #これ以下は`terraform init`で自動で生成される
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
## フォルダと空ファイルを用意

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
$ touch aws-vpc.tf aws-sg.tf aws-ec2.tf aws-rds.tf aws-alb.tf aws-s3.tf variables.tf
$ mkdir ../stage
$ cd ../stage
$ touch main.tf variables.tf terraform.tfvars
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
$ tree      #上述のフォルダ構成になっているはず
```

## Backend機能を使う
先に以下のコマンドでS3バケットを生成しておく
```bash
$ aws s3 mb s3://tf-raisetech-lec10cfn
make_bucket: tf-raisetech-lec10cfn
```
backendの定義をmain.tfに追記する
```bash
# backendの定義
terraform {
  backend "s3" {
    bucket = "tf-raisetech-lec10cfn"
    key = "tf-raisetech-lec10cfn/stage/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```
## 各moduleを作成
stageのディレクトリで`terraform init`してから以下の順に操作
```bash
$ terraform fmt
$ terraform validate    #計10回はトライアンドエラーしていました。。
$ terraform apply
```
いろいろ参考にして実装しました。ほとんどリファレンスですが、よろしければ「参考」を展開ください。

<details><summary>参考</summary>

### main.tfを編集
#### module構成の参考記事
他にも多くの記事をみましたが、構成のこともわかるし、それにともなう変数の使い方もわかりやすかったものをピックアップして以下にメモします。
* https://dev.classmethod.jp/articles/directory-layout-bestpractice-in-terraform/
* https://qiita.com/reireias/items/253529c889cafb3fa4c7


### vpc.tfを編集
#### 参考記事
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

### sg.tfを編集
#### 参考記事
* https://dev.classmethod.jp/articles/terraform-security-group/
* https://beyondjapan.com/blog/2022/10/terraform-how-to-use-security-group/
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
    * 特にRDS用のセキュリティグループのインバウンドルールにおけるソースをEC2用のセキュリティグループIDにするという方法の参照として使いました。↓の参考記事も同様です。
* https://ohshige.hatenablog.com/entry/2019/11/11/190000
* https://qiita.com/suzuki0430/items/2dbd88dfb5ed53016914

### ec2.tfを編集
#### 参考記事
* https://zenn.dev/supersatton/articles/c87853cc5a3dbd
* https://qiita.com/okdyy75/items/73641a0247bae1fa7f31
* https://khasegawa.hatenablog.com/entry/2017/10/03/000000
* [[Terraform][CloudFormation]最新のAMI IDの取得方法](https://qiita.com/to-fmak/items/7623ee6e15249a4bcedd#:~:text=%E3%80%8CData%20Source%E3%80%8D%E3%81%A7%E6%9C%80%E6%96%B0%E3%81%AE,AMI%E3%82%92%E5%8F%96%E5%BE%97%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%99%E3%80%82)
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance

### rds.tfを編集
#### 参考記事
* https://zenn.dev/suganuma/articles/fe14451aeda28f
* https://tech.isid.co.jp/entry/terraform_manage_master_user_password
* https://zenn.dev/yumemi_inc/articles/081b0190db8260
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance

### alb.tfとs3.tfを編集
#### 参考記事
* https://katsuya-place.com/terraform-elb-basic/
* https://cloud5.jp/terraform-alb/
* https://y-ohgi.com/introduction-terraform/handson/alb/
* 公式
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
  * https://www.terraform.io/docs/providers/aws/r/lb_listener.html
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

</details>

## 結果
### コーディングや結果
下表の通りです。
* コーディングの説明はなるべくコメントアウトとしていれました
* 「結果」はマネジメントコンソール画面のキャプチャを撮りためているので、それを上げる予定です
* 「トランアンドエラー」もキャプチャをとりためているので、それを上げていく予定です
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

### 簡易的な結果確認
* EC2にNginxをインストール・起動し、ALBからブラウザでアクセスして確認しました。RDS側の確認まではやっていません。
![Nginx画面](image/tfで構築したALBのDNSからブラウザでアクセス.png)
* 一部トライアンドエラーを以下に記載します。上図左のegressについてのルール追加の裏話です
  * 最初、ALBに適用しているセキュリティグループについてはアウトバウンド(egress)を記述していませんでした。
  * そのせいではじめは「504 Gateway Timeout」エラーが返されていました。（コンソール見て確認しました）
  * 調べるとTerraformはアウトバウンドルールを明示的に記述しないとアウトバウンドルールが反映されないようでした。

### 後始末`terraform destroy`時の苦悩
[TryandError10_terraform-destroyできない件.md](TryandError10_terraform-destroyできない件.md)にまとめました

## まとめ
* Terraformを学習することで、CloudFormationの時以上に、深くリソースを理解することができました。
* AzureやGCPなどほかのクラウドインフラ版にも挑戦したいと思います。
* Terraform の特徴などを、CloudFormationと比較して、主観で以下にメモします。
  * Outputを記述しなくても、他リソースのidやarnなどを引用することができる
  * egressのルール、protectionのルールなど、明示的に記述しないとリソースに反映されない
  * どのリソースがTerraform で作ったものかを、各現場の運用ルールしたがって管理しておく必要あり（CloudFormationはマネコンでわかる）
  * 変数定義を各リソースのファイルではなく、別のファイルでまとめられるので、環境ごとの定義が変更しやい
  * リソース削除の時が少し面倒かも（それも対応可能そうではある）

