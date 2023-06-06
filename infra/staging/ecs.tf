resource "aws_ecs_cluster" "this" {
  name = "wca-registration-staging"
  tags = {
    Env = "staging"
  }
}