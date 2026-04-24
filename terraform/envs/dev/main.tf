# ------------------------------------------------------------------
# Dev environment ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â calls the VPC module
# ------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = "10.0.0.0/16"
  azs      = ["eu-west-2a", "eu-west-2b"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  db_subnets      = ["10.0.21.0/24", "10.0.22.0/24"]

  # Dev: HA pattern (2 NATs). We pay during active sessions, destroy after.
  enable_nat_gateway = true
  single_nat_gateway = false
}

# ------------------------------------------------------------------
# Outputs ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â bubble up from the module for easy reference
# ------------------------------------------------------------------
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.db_subnet_ids
}


# ------------------------------------------------------------------
# ECR repository for application images
# ------------------------------------------------------------------
module "ecr_app" {
  source = "../../modules/ecr"

  project_name    = var.project_name
  environment     = var.environment
  repository_name = "app"
}

output "ecr_repository_url" {
  value = module.ecr_app.repository_url
}


# ------------------------------------------------------------------
# EKS cluster
# ------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  kubernetes_version = "1.33"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.small"]
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 3

  # Bootstrap admin: you (IAM user running Terraform)
  admin_user_arn = "arn:aws:iam::373631301915:user/Inaam"
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}



output "alb_controller_role_arn" {
  value = module.eks.alb_controller_role_arn
}

