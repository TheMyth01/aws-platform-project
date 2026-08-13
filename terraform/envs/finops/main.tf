# ------------------------------------------------------------------
# Project-scoped monthly budget
# ------------------------------------------------------------------
resource "aws_budgets_budget" "project_monthly" {
  name         = "${var.project_name}-monthly-cost"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_amount)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name = "TagKeyValue"

    values = [
      "user:Project${"$"}${var.project_name}"
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}

# ------------------------------------------------------------------
# Project-scoped Cost Anomaly Detection monitor
# ------------------------------------------------------------------
resource "aws_ce_anomaly_monitor" "project" {
  name         = "${var.project_name}-cost-monitor"
  monitor_type = "CUSTOM"

  monitor_specification = jsonencode({
    Tags = {
      Key    = "Project"
      Values = [var.project_name]
    }
  })
}

# ------------------------------------------------------------------
# Daily anomaly email subscription
# ------------------------------------------------------------------
resource "aws_ce_anomaly_subscription" "project_daily" {
  name      = "${var.project_name}-daily-anomaly-alerts"
  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.project.arn
  ]

  subscriber {
    type    = "EMAIL"
    address = var.alert_email
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = [tostring(var.anomaly_absolute_threshold)]
    }
  }
}
