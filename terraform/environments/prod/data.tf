data "aws_caller_identity" "current" {}

locals {
  owner = split("/", data.aws_caller_identity.current.arn)[1]
  common_tags = merge(var.tags, {
    Owner = local.owner
    ManagedBy = "terraform"
    Environment = var.environment
  })
}
