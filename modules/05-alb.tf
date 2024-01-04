############
# リソース定義
############
#ALB作成
resource "aws_lb" "alb_tf" {
  name               = "alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.public_1a_sn.id, aws_subnet.public_1c_sn.id]
#削除保護はデフォルトでfalse(off)ですが本番利用する際は基本Onだとおもうので今回は明示的に記述します。
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.s3-alb-log240104tf.id
    prefix  = "alb-tf"
    enabled = true
  }

  tags = {
    Name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }
}

#ターゲットグループ作成
resource "aws_lb_target_group" "alb-tg_tf" {
  name             = "alb-tg-tf"
  target_type      = "instance"
  protocol_version = "HTTP1"
  port             = 80
  protocol         = "HTTP"
  vpc_id           = aws_vpc.main_vpc.id

  tags = {
    name = "${var.create_date}-${var.create_by}-${var.my_env}"
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200,301"
  }
}

#ターゲットグループにEC2インスタンスを登録しターゲットグループをALBと紐づける
#EC2インスタンスに登録
resource "aws_lb_target_group_attachment" "alb-tg-ec2_tf" {
  target_group_arn = aws_lb_target_group.alb-tg_tf.arn
  target_id        = aws_instance.ec2_tf.id
}

# Listener定義作成してALBと紐づける
resource "aws_lb_listener" "alb-listener_tf" {
  load_balancer_arn = aws_lb.alb_tf.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg_tf.arn
  }
}


