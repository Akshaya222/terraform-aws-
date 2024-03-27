resource "aws_security_group" "application-sg" {
  vpc_id = aws_vpc.custom-vpc-application.id
  name   = "application-security-group"
}

resource "aws_security_group" "application-lb-sg" {
  vpc_id = aws_vpc.custom-vpc-application.id
  name   = "application-lb-security-group"
}

resource "aws_security_group_rule" "allow-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application-sg.id
  protocol          = "tcp"
}

resource "aws_security_group_rule" "allow-nodejs-port" {
  type                     = "ingress"
  from_port                = 3001
  to_port                  = 3001
  source_security_group_id = aws_security_group.application-lb-sg.id
  security_group_id        = aws_security_group.application-sg.id
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "traffic-on-lb-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application-lb-sg.id
  protocol          = "tcp"
}
