resource "aws_lb" "application-lb" {
  name               = "nodejs-application-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.application-subnet-a.id, aws_subnet.application-subnet-b.id]
  security_groups    = [aws_security_group.application-lb-sg.id]
  ip_address_type    = "ipv4"
}

resource "aws_lb_target_group" "application-tg" {
  name        = "nodejs-application-tg"
  port        = 3001
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.custom-vpc-application.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 50
    timeout             = 10
    protocol            = "HTTP"
    path                = "/"
  }
}

resource "aws_acm_certificate" "nodejs-application-certificate" {
  domain_name       = "application.akshaya.cloud"
  validation_method = "DNS"
}

resource "aws_lb_listener" "application-listener" {
  load_balancer_arn = aws_lb.application-lb.arn
  certificate_arn   = aws_acm_certificate.nodejs-application-certificate.arn
  port              = 443
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application-tg.arn
  }
}

resource "aws_route53_record" "cname-record" {
  zone_id = "Z045108419ZU8E5LWST70"
  name    = "application.akshaya.cloud"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.application-lb.dns_name]
}

