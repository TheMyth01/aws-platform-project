variable "aws_region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name, used as a prefix for resources"
  type        = string
  default     = "aws-platform"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
}
