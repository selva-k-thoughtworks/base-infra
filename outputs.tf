output "child_service_account_access_key_id" {
  value       = aws_iam_access_key.child_key.id
  description = "Access key ID for the child service account."
  sensitive   = true
}

output "child_service_account_secret_access_key" {
  value       = aws_iam_access_key.child_key.secret
  description = "Secret access key for the child service account."
  sensitive   = true
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint."
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name."
} 