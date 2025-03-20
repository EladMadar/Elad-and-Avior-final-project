# Production Environment Configuration
# add to vars According do best practice
locals {
  environment = "prod"
  region     = "us-east-1"  # Change as needed
}

module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = local.environment
  aws_region  = local.region
  vpc_cidr    = var.vpc_cidr

  tags = var.tags
}

module "eks" {
  source = "../../modules/eks"

  project           = var.project
  environment       = local.environment
  aws_region        = local.region
  cluster_version   = var.eks_cluster_version
  private_subnet_ids = module.vpc.private_subnets

  # Cost-optimized node configuration
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = 2
  node_min_size      = 1
  node_max_size      = 5

  tags = var.tags

  depends_on = [module.vpc]
}

module "rds" {
  source = "../../modules/rds"

  project              = var.project
  environment         = local.environment
  vpc_id              = module.vpc.vpc_id
  database_subnet_ids = module.vpc.database_subnets
  eks_security_group_id = module.eks.cluster_security_group_id

  # Cost-optimized instance configuration
  instance_class     = var.rds_instance_class
  allocated_storage = 20

  tags = var.tags

  depends_on = [module.vpc, module.eks]
}

module "redis" {
  source = "../../modules/redis"

  project              = var.project
  environment         = local.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnets
  eks_security_group_id = module.eks.cluster_security_group_id

  # Cost-optimized node configuration
  node_type = var.redis_node_type

  tags = var.tags

  depends_on = [module.vpc, module.eks]
}

module "waf" {
  source = "../../modules/waf"

  project     = var.project
  environment = local.environment
  # add rate_limit to vars
  # Production WAF settings
  rate_limit = 2000  # Adjust based on expected traffic
  blocked_countries = []  # Add country codes to block if needed
  log_retention_days = 30

  tags = var.tags
}

module "alb" {
  source = "../../modules/alb"

  project           = var.project
  environment      = local.environment
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  certificate_arn  = var.certificate_arn
  waf_acl_arn     = module.waf.web_acl_arn

  tags = var.tags

  depends_on = [module.vpc, module.waf]
}
