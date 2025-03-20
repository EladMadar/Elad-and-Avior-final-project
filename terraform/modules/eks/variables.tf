variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the EKS API"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Warning: Restrict this in production
}

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3a.medium", "t3.medium"]  # Cost-effective instance types
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
