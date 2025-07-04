# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Create Subnet for EKS (Fargate)
resource "aws_subnet" "eks_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet"
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
      Sid = ""
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
        Service = "eks-fargate.amazonaws.com"
      },
      Effect = "Allow",
      Sid = ""
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
    subnet_ids = [aws_subnet.eks_subnet.id]
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
      Sid = ""
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
