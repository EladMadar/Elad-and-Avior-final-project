variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS listener (optional)"
  type        = string
  default     = null
}

variable "waf_acl_arn" {
  description = "ARN of WAF Web ACL to associate with ALB"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain ALB logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
