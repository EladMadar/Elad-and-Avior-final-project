variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "rate_limit" {
  description = "Number of requests allowed per 5 minutes per IP"
  type        = number
  default     = 2000
}

variable "ip_rate_limit" {
  description = "Number of requests allowed per 5 minutes for specific IPs"
  type        = number
  default     = 0  # Disabled by default
}

variable "blocked_countries" {
  description = "List of country codes to block"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain WAF logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
