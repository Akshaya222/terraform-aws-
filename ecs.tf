resource "aws_ecs_cluster" "application-cluster" {
  name = "application-ecs-cluster"
}

resource "aws_iam_role" "application-task-execution-role" {
  name = "application-task-execution-iam-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "application-execution-task-policy" {
  name = "application-task-iam-policy"
  role = aws_iam_role.application-task-execution-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Sid" : "AbilityToCheckoutFromEcr",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ],
        "Resource" : "*"
      },
    ]
  })
}

resource "aws_ecs_task_definition" "application-task-defination" {
  family = "application-task-defination"
  container_definitions = jsonencode([
    {
      name  = "node-js-application"
      image = "668062134171.dkr.ecr.ap-south-1.amazonaws.com/my-application:latest"
      memoryReservation : 256,
      essential = true
      portMappings = [
        {
          containerPort = 3001
          hostPort      = 3001
        }
      ]
    }
  ])
  execution_role_arn = aws_iam_role.application-task-execution-role.arn
}

resource "aws_ecs_service" "application-service" {
  name            = "application-service"
  cluster         = aws_ecs_cluster.application-cluster.id
  task_definition = aws_ecs_task_definition.application-task-defination.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.application-tg.arn
    container_port   = 3001
    container_name   = "node-js-application"
  }

}
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.application-cluster.name}/${aws_ecs_service.application-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs-asg-policy" {
  name               = "cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
    disable_scale_in   = false
  }
}

resource "aws_ecr_repository" "foo" {
  name                 = "my-application"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}