# AWS Load Balancer Controller configuration

module "alb_controller" {
  source = "./modules/alb-controller"

  cluster_name     = module.eks.cluster_name
  node_role_name   = "status-page-prod-cluster-node-role"
  public_subnet_ids = module.vpc.public_subnet_ids

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
    Owner       = "eladmadr"
  }
}
