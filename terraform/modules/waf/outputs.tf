output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "log_group_name" {
  description = "The name of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf.name
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf.arn
}
