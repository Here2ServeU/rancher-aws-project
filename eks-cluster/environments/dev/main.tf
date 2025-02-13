provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "t2s-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = ["subnet-abc123", "subnet-def456"]
  }
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_group_name = "t2s-eks-nodes"
  node_role_arn = aws_iam_role.eks_role.arn
  subnet_ids    = ["subnet-abc123", "subnet-def456"]
  instance_types = ["t3.medium"]
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
}