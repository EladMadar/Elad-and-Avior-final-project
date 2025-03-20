output "endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.main.cache_nodes[0].port
}

output "security_group_id" {
  description = "ID of the security group created for Redis"
  value       = aws_security_group.redis.id
}

output "secret_arn" {
  description = "ARN of the secret containing Redis connection information"
  value       = aws_secretsmanager_secret.redis.arn
}
