resource "aws_elasticache_cluster" "this" {
  cluster_id = "wca-redisstaging"
  engine = "redis"
  engine_version = "7.0"
  maintenance_window = "fri:10:00-fri:11:00"
  node_type = "cache.t4g.micro"
  num_cache_nodes = 1
  port = 6379
  parameter_group_name = "redis7allkeyslfu"
  subnet_group_name = var.elasticache_subnet_group_name
  availability_zone = var.availability_zones[0]
  security_group_ids = [aws_security_group.cache-sg.id]
  tags = {
    Env = "staging"
  }
}

resource "aws_security_group" "cache-sg" {
  name        = "${var.name_prefix}-cache"
  description = "Staging Cache"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-cache"
    Env = "staging"
  }
}
resource "aws_security_group_rule" "cache_cluster_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.cache-sg.id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "TCP"
  source_security_group_id = var.cluster_security_id
  description              = "Redis Cache ingress"
}