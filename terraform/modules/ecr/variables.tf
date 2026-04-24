variable "project_name" {
  description = "Project name, used in repository naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository (appended after project-env)"
  type        = string
}

variable "image_tag_mutability" {
  description = "MUTABLE allows overwriting tags; IMMUTABLE prevents it (production safer)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable automatic vulnerability scanning on push"
  type        = bool
  default     = true
}
