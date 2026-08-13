# Tagging Strategy

## Status

**IMPLEMENTED:** five default tags are applied through the Terraform AWS provider.

**KNOWN GAP:** tag coverage has not yet been proven on the EC2 instances, EBS volumes and ENIs created underneath the EKS managed node group.

**TO VERIFY:** AWS Billing cost allocation tag activation has not yet been evidenced.

## Mandatory tags

| Tag | Purpose | Example |
|---|---|---|
| Project | Project identifier | aws-platform |
| Environment | Lifecycle environment | dev |
| Owner | Accountable owner | inaam |
| CostCenter | Billing allocation | platform-eng |
| ManagedBy | Provisioning/management mechanism | terraform |

Terraform source: `terraform/envs/dev/providers.tf`.

## Why this matters

- **Cost allocation:** tag dimensions allow spend to be grouped to an environment, owner or cost centre once cost allocation tags are active in Billing.
- **Showback:** CostCenter and Owner support visibility and accountability without requiring chargeback.
- **Lifecycle analysis:** Environment distinguishes dev from future staging/production patterns.
- **Ownership:** Owner identifies who should investigate or approve an optimisation.

## What `default_tags` proves

The Terraform provider merges these tags into AWS resources that support provider-level default tagging.

It does **not** prove that every downstream resource created by a managed AWS service inherits them.

In particular, the project currently treats EKS worker-resource tag propagation as a known gap to test and fix before the next instrumented run.

## Cost allocation tag activation

Resource tags and AWS Billing cost allocation tags are separate concepts.

- Resource tags are written to AWS resources.
- Cost allocation tag activation makes selected tag keys usable as billing dimensions in Cost Explorer, Data Exports/CUR and Budgets.

The repository must not claim cost allocation tags are active until evidence is captured using the Billing console or AWS CLI.

Planned evidence:

```powershell
aws ce list-cost-allocation-tags --status Active
```

All five required keys will be confirmed before any historical backfill request is submitted.

## Historical backfill

April 2026 tag backfill will be attempted after activation is confirmed. Historical allocation can only recover tag values that were actually attached to resources during the historical period.

Because the managed node-group worker resources may not have carried the five tags, some April EC2/EBS spend may remain unallocated even after backfill. That outcome will be documented rather than hidden.

## Target allocation KPI

Future instrumented runs will calculate:

**Allocation coverage % = tagged allocatable spend / total allocatable spend**

The target is at least 99%, but the target will not be claimed as achieved until measured from exported billing data.

## Planned worker-resource fix

Before the next full EKS run, the node group will be updated to use a launch template with tag specifications for the underlying resource types where supported. The change will be validated through AWS-side resource inspection and then through an unallocated-spend query in CUR 2.0/Athena.

## Exceptions

Not every AWS charge can necessarily be allocated using resource tags. Service-level and untaggable charges will be shown explicitly as unallocated/shared rather than forced into an artificial allocation rule.
