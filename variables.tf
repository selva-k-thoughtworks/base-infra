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

variable "subnet_cidr_1" {
  description = "Subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_2" {
  description = "Subnet CIDR block"
  default     = "10.0.2.0/24"
}
