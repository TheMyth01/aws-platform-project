variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "inaam"
}

variable "cost_center" {
  description = "Cost centre tag"
  type        = string
  default     = "platform-eng"
}

variable "admin_user_arn" {
  description = "IAM principal ARN granted EKS cluster admin access. Set locally via terraform.tfvars or TF_VAR_admin_user_arn; do not hardcode account-specific ARNs in the repository."
  type        = string
}
