variable "domain_name" {
  description = "The root domain name (e.g., example.com)"
  type        = string
  default     = "elad-avior.com"
}

variable "subdomain" {
  description = "The subdomain to create (e.g., status)"
  type        = string
  default     = "status"
}

variable "lb_dns_name" {
  description = "The DNS name of the load balancer"
  type        = string
}

variable "ttl" {
  description = "The TTL for the DNS record in seconds"
  type        = number
  default     = 300
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
