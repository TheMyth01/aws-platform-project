variable "aws_region" {
  description = "AWS region used for provider operations"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project cost-allocation tag value monitored by FinOps controls"
  type        = string
  default     = "aws-platform"
}

variable "alert_email" {
  description = "Email address that receives project FinOps alerts"
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly project budget in USD"
  type        = number
  default     = 5
}

variable "anomaly_absolute_threshold" {
  description = "Minimum anomaly impact in USD for the daily anomaly alert"
  type        = number
  default     = 1
}
