# Production Environment Configuration

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

locals {
  environment = var.environment
  region      = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = local.environment
  aws_region  = local.region
  vpc_cidr    = var.vpc_cidr

  tags = local.common_tags
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

  tags = local.common_tags

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

  tags = local.common_tags

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

  tags = local.common_tags

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

  tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  project           = var.project
  environment      = local.environment
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  certificate_arn  = var.certificate_arn
  waf_acl_arn     = module.waf.web_acl_arn

  tags = local.common_tags

  depends_on = [module.vpc, module.waf]
}

# Add the new Kubernetes module for the Status Page application
module "kubernetes" {
  source = "../../modules/kubernetes"

  # Pass required values from other modules
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  cluster_name           = module.eks.cluster_name
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnets
  
  # Database information
  db_host          = module.rds.db_instance_address
  db_name          = "statuspage"
  db_user          = "statuspage" 
  db_password      = "postgres"
  db_port          = "5432"
  
  # Certificate information for HTTPS
  certificate_arn  = var.certificate_arn
  domain_name      = "status.elad-avior.com"
  
  # Repository information
  ecr_repo_url     = "992382545251.dkr.ecr.us-east-1.amazonaws.com/statuspage-app"

  depends_on = [
    module.eks,
    module.rds,
    module.redis
  ]
}

# Output the URLs for easy access
output "status_page_url" {
  description = "URL to access the Status Page"
  value       = module.kubernetes.status_page_url
}

output "grafana_url" {
  description = "URL to access Grafana dashboards"
  value       = module.kubernetes.grafana_url
}
