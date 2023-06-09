resource "aws_ecs_cluster" "this" {
  name = "wca-registration-staging"
  tags = {
    Env = "staging"
  }
}

resource "aws_ecs_service" "this" {
  name    = "Staging-Service"
  cluster = aws_ecs_cluster.this.id
  task_definition                    = data.aws_ecs_task_definition.this.arn
  desired_count                      = 1
  scheduling_strategy                = "REPLICA"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 0
  launch_type = "FARGATE"
  enable_execute_command = true

  network_configuration {
    security_groups = [var.cluster_security_id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "staging-handler"
    container_port   = 3000
  }

  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name = var.name_prefix
    Env = "staging"
  }
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
