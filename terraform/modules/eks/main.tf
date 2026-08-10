# ------------------------------------------------------------------
# Locals — computed once, used throughout
# ------------------------------------------------------------------
locals {
  full_cluster_name = "${var.project_name}-${var.environment}-${var.cluster_name}"
}

# ------------------------------------------------------------------
# IAM role for the EKS cluster control plane
# ------------------------------------------------------------------
resource "aws_iam_role" "cluster" {
  name = "${local.full_cluster_name}-cluster-role"

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

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ------------------------------------------------------------------
# EKS cluster (control plane)
# ------------------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = local.full_cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # Modern auth — API mode (access entries), no more aws-auth ConfigMap pain
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

# ------------------------------------------------------------------
# OIDC provider for IRSA (pod-level IAM, needed for ALB controller in Week 5)
# ------------------------------------------------------------------
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# ------------------------------------------------------------------
# IAM role for worker nodes
# ------------------------------------------------------------------
resource "aws_iam_role" "node" {
  name = "${local.full_cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ------------------------------------------------------------------
# Custom launch template for managed nodes
#
# EKS node group tags do not propagate to the underlying EC2 resources.
# Tag specifications here ensure worker EC2 instances, EBS volumes and ENIs
# receive the same FinOps allocation tags as the rest of the platform.
# ------------------------------------------------------------------
resource "aws_launch_template" "node" {
  name_prefix = "${local.full_cluster_name}-nodes-"

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.resource_tags, {
      Name = "${local.full_cluster_name}-node"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.resource_tags, {
      Name = "${local.full_cluster_name}-node-volume"
    })
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = merge(var.resource_tags, {
      Name = "${local.full_cluster_name}-node-eni"
    })
  }

  tags = merge(var.resource_tags, {
    Name = "${local.full_cluster_name}-node-launch-template"
  })
}

# ------------------------------------------------------------------
# Managed node group — 2 worker EC2 instances in private subnets
# ------------------------------------------------------------------
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.full_cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(var.resource_tags, {
    Name = "${local.full_cluster_name}-nodes"
  })

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]
}


# ------------------------------------------------------------------
# AWS Load Balancer Controller IAM policy + IRSA role
# ------------------------------------------------------------------
resource "aws_iam_policy" "alb_controller" {
  name        = "${local.full_cluster_name}-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/alb-controller-policy.json")
}

resource "aws_iam_role" "alb_controller" {
  name = "${local.full_cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })

  tags = {
    Name = "${local.full_cluster_name}-alb-controller-role"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
