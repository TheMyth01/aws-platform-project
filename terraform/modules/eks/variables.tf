variable "project_name" {
  description = "Project name, used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (appended after project-env)"
  type        = string
  default     = "main"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane"
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster runs"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS (control plane ENIs + worker nodes)"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes (for autoscaling later)"
  type        = number
  default     = 3
}

variable "admin_user_arn" {
  description = "IAM user ARN to grant cluster admin (kubectl access from laptop)"
  type        = string
}
