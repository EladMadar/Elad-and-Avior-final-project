variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.medium"  # ARM-based instance for cost optimization
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "statuspage"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "statuspage"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
