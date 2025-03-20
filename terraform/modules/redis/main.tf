# Redis Module - Creates a cost-optimized ElastiCache Redis cluster

locals {
  identifier = "${var.project}-${var.environment}-redis"
}

# Security Group for Redis
resource "aws_security_group" "redis" {
  name_prefix = "${local.identifier}-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  tags = merge(var.tags, {
    Name = "${local.identifier}-sg"
  })
}

# Subnet group for Redis
resource "aws_elasticache_subnet_group" "main" {
  name       = local.identifier
  subnet_ids = var.private_subnet_ids

  tags = var.tags
}

# Parameter group for Redis
resource "aws_elasticache_parameter_group" "main" {
  family = "redis7"
  name   = local.identifier

  # Cost-optimized parameters
  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  tags = var.tags
}

# Redis Cluster
resource "aws_elasticache_cluster" "main" {
  cluster_id           = local.identifier
  engine              = "redis"
  node_type           = var.node_type
  num_cache_nodes     = 1  # Single node for cost optimization
  parameter_group_name = aws_elasticache_parameter_group.main.name
  port                = 6379
  
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]

  # Cost optimization settings
  engine_version       = "7.0"  # Latest stable version
  maintenance_window   = "sun:05:00-sun:06:00"

  tags = merge(var.tags, {
    Name = local.identifier
  })
}

# Store Redis connection info in Secrets Manager
resource "aws_secretsmanager_secret" "redis" {
  name = "${local.identifier}-connection"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    host = aws_elasticache_cluster.main.cache_nodes[0].address
    port = aws_elasticache_cluster.main.cache_nodes[0].port
  })
}
