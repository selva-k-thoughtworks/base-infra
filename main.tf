# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Create Subnet for EKS (Fargate)
resource "aws_subnet" "eks_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_1
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "my-subnet-1"
  }
}

resource "aws_subnet" "eks_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_2
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "my-subnet-2"
  }
}

# Create IAM role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = {
    Name = "eks-cluster-role"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create IAM role for Fargate (Worker Node)
resource "aws_iam_role" "eks_fargate_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com" # Added Fargate service principal
        ]
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = {
    Name = "eks-fargate-role"
  }
}

# Attach the EKS Fargate policy to the role
resource "aws_iam_role_policy_attachment" "eks_fargate_policy" {
  role       = aws_iam_role.eks_fargate_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Create "child" IAM role with Storage Admin and Kubernetes Cluster Admin roles
resource "aws_iam_role" "child_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = {
    Name = "child-service-account"
  }
}

# Attach policies to child role
resource "aws_iam_role_policy_attachment" "storage_admin" {
  role       = aws_iam_role.child_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_admin" {
  role       = aws_iam_role.child_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create EKS Fargate Profile
resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "my-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]

  selector {
    namespace = "default" # You can add more namespaces if necessary
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_fargate_policy
  ]
}

