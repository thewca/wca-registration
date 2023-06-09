resource "aws_ecr_repository" "this" {
  name         = var.name_prefix
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images older than 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}

# We deploy the worker using ECS update service because there is no traffic to it
# for a load balancer based traffic shift deployment
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecs/update-service.html

