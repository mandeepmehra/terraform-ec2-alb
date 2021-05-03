resource "aws_security_group" "albsg" {
  name = "albsg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "weblb" {
  name            = "webserveralb"
  internal        = false
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.albsg.id]
}


resource "aws_lb_target_group" "myalbtg" {
  name     = "myalb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_alb_target_group_attachment" "ia" {
  count            = var.webserver_count
  target_group_arn = aws_lb_target_group.myalbtg.arn
  target_id        = aws_instance.test[count.index].id

}

resource "aws_lb_listener" "weblisterner" {
  load_balancer_arn = aws_alb.weblb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalbtg.arn
  }
}

output "albdns" {
  value = aws_alb.weblb.dns_name
}