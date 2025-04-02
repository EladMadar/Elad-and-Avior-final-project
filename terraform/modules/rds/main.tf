# RDS Module - Creates a cost-optimized PostgreSQL RDS instance

locals {
  identifier = "${var.project}-${var.environment}-db"

  # Ensure consistent tags across all resources
  common_tags = merge(
    var.tags,
    {
      Name = "${var.project}-${var.environment}"
      Project = var.project
      Environment = var.environment
      Component = "database"
    }
  )
}

# Random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = false
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "${local.identifier}-password"
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.db_name
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${local.identifier}-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  tags = merge(var.tags, {
    Name = "${local.identifier}-sg"
  })
}

# Subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = local.identifier
  subnet_ids = var.database_subnet_ids

  tags = merge(var.tags, {
    Name = "${local.identifier}-subnet-group"
  })
}

# Parameter group for PostgreSQL
resource "aws_db_parameter_group" "main" {
  name_prefix = "${local.identifier}-"
  family      = "postgres14"

  # Cost-optimized parameters
  parameter {
    name         = "shared_buffers"
    value        = "8192"  # 8MB - static value
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_connections"
    value        = "100"  # Adjust based on your needs
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = "4096"  # 4MB
    apply_method = "pending-reboot"
  }

  tags = local.common_tags
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = local.identifier

  engine         = "postgres"
  engine_version = "14"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true
  
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = 5432

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name

  # Backup configuration
  backup_retention_period = 14  # Keep backups for 14 days as per requirements
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  # Cost optimization settings
  multi_az                = var.environment == "prod"  # Only use Multi-AZ in production
  skip_final_snapshot     = true  # Skip final snapshot to avoid issues
  delete_automated_backups = false  # Keep automated backups
  
  # Performance Insights (free tier)
  performance_insights_enabled = true
  performance_insights_retention_period = 7  # Free tier: 7 days retention

  # Enhanced monitoring (optional, comment out if not needed)
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = merge(var.tags, {
    Name = local.identifier
  })
}

# IAM role for enhanced monitoring
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${local.identifier}-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
