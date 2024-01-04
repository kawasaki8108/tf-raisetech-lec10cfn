############
# データ取得の定義
############
#ALBアカウントIDを取得するために使用
data "aws_elb_service_account" "elb-service-account" {}
#取得したALBアカウントに後述で作るバケットへPUTする許可を与えるポリシー作成
data "aws_iam_policy_document" "s3-alb-log-policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.s3-alb-log240104tf.id}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.elb-service-account.id]
    }
  }
}
############
# リソースの定義
############
#前述のポリシーと後述のバケットの紐づけ
#(aws_s3_bucket内に記述してもいいがTerraformに非推奨といわれるのでこの形)
resource "aws_s3_bucket_policy" "s3-alb-log-bucket-policy" {
  bucket = aws_s3_bucket.s3-alb-log240104tf.id
  policy = data.aws_iam_policy_document.s3-alb-log-policy.json
}

#バケットを作成
resource "aws_s3_bucket" "s3-alb-log240104tf" {
  bucket        = "s3-alb-log240104tf"
  force_destroy = true
  lifecycle_rule {
    enabled = true
    expiration {
      days = 15
    }
  }
}

# S3 Public Access Block
## パブリックアクセスはしないため全て有効にする。
resource "aws_s3_bucket_public_access_block" "s3-alb-log-access" {
  bucket                  = aws_s3_bucket.s3-alb-log240104tf.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

