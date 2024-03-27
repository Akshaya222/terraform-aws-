resource "aws_iam_instance_profile" "application-ec2-profile" {
  role = aws_iam_role.ec2-instance-iam-role.id
}

resource "aws_launch_configuration" "application-lc" {
  name                        = "application-launch-configuration"
  image_id                    = "ami-0318141abde6bc637"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.application-ec2-profile.id
  security_groups             = [aws_security_group.application-sg.id]
  associate_public_ip_address = "true"
  key_name                    = "terraform-keys"
  user_data                   = <<-EOF
              #!/bin/bash
              echo 'ECS_CLUSTER=${aws_ecs_cluster.application-cluster.name}' >> /etc/ecs/ecs.config
              EOF
}

resource "aws_autoscaling_group" "application-asg" {
  name                 = "application-asg"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.application-lc.id
  vpc_zone_identifier  = [aws_subnet.application-subnet-a.id, aws_subnet.application-subnet-b.id]
}