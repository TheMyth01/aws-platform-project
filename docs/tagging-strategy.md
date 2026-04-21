# Tagging Strategy

All AWS resources must carry these tags. Enforced via Terraform `default_tags` in every provider block.

| Tag         | Purpose                      | Example              |
|-------------|------------------------------|----------------------|
| Project     | Project identifier           | aws-platform         |
| Environment | Lifecycle environment        | dev / staging / prod |
| Owner       | Responsible engineer         | inaam                |
| CostCenter  | Billing attribution          | platform-eng         |
| ManagedBy   | Provisioning tool            | terraform            |

## Why this matters (FinOps)

- **Cost allocation**: Cost Explorer and CUR can group spend by any tag. Without tags, you cannot answer "how much did dev cost this month?"
- **Showback/chargeback**: CostCenter tag enables reporting spend back to the responsible team.
- **Anomaly detection**: Environment tag lets you spot when dev spend suddenly matches prod.
- **Rightsizing**: Owner tag tells you who to speak to when a resource is oversized.

## Enforcement

- Terraform `default_tags` applied in every provider block — tags inherited by all resources.
- Resources that do not support tags (e.g. some IAM entities) are exceptions, documented per case.
- Manually-created resources are forbidden. IaC only.

## Verification

Monthly review via AWS Cost Explorer filtered by tag. Untagged spend should be <1%.
