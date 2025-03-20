# Production Environment Variables

variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "List of EC2 instance types for EKS node groups"
  type        = list(string)
  default     = ["t3a.medium", "t3.medium"]  # Cost-effective instance types
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.medium"  # ARM-based instance for cost optimization
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t4g.medium"  # ARM-based instance for cost optimization
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
