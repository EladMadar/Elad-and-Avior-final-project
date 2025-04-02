# General Variables
variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "elad-and-avior-status-page"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# EKS Variables
variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "List of EC2 instance types for EKS node groups"
  type        = list(string)
  default     = ["t3a.medium", "t3.medium"] # Cost-effective instance types
}

# RDS Variables
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.medium" # ARM-based instance for cost optimization
}

# Elasticache Variables
variable "redis_node_type" {
  description = "Elasticache Redis node type"
  type        = string
  default     = "cache.t4g.medium" # ARM-based instance for cost optimization
}

# WAF Variables
variable "waf_block_rules" {
  description = "List of IP ranges to block"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
