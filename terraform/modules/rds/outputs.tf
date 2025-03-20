output "endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "The port the RDS instance is listening on"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.main.db_name
}

output "secret_arn" {
  description = "ARN of the secret containing database credentials"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "security_group_id" {
  description = "ID of the security group created for RDS"
  value       = aws_security_group.rds.id
}
