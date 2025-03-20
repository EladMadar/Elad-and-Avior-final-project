variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Redis will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

variable "node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t4g.medium"  # ARM-based instance for cost optimization
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
