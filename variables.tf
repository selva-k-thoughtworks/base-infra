variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  default     = "selva-test-eks-cluster"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  default     = "10.0.0.0/24"
}
