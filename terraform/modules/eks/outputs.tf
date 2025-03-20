output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.cluster.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN for EKS node group"
  value       = aws_iam_role.node_group.arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
