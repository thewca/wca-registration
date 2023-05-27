resource "aws_ecs_cluster" "this" {
  name = "registration-staging"
  tags = {
    Env = "staging"
  }
}