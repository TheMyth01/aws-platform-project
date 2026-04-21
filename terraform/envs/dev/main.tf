# ------------------------------------------------------------------
# Dev environment — calls the VPC module
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
# Outputs — bubble up from the module for easy reference
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
