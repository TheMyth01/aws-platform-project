# Tag-aware Athena showback - 10 to 15 August 2026

## Status

**MEASURED / IMPLEMENTED**

This evidence captures a tag-aware showback over CUR 2.0 gross `Usage` cost for the controlled August experiment window.

The query logic is committed in `sql/cur-showback.sql`.

## Scope

- Billing source: CUR 2.0
- Query engine: Amazon Athena
- Database: `finops-cur-2`
- Table: `finops_cur_2`
- Window: 2026-08-10 00:00:00 UTC to 2026-08-15 00:00:00 UTC
- Charge type included: `Usage`
- Metric: unblended gross cost
- Credits and other billing adjustments: excluded from the showback allocation calculation

The five activated project cost-allocation tags are represented in CUR as:

- `user_project`
- `user_environment`
- `user_owner`
- `user_cost_center`
- `user_managed_by`

A row is treated as allocated only when all five ownership dimensions are populated.

## Cost-weighted allocation coverage

Athena query ID: `6c524d4c-b382-41ed-9597-c29c81634954`

| Allocation status | CUR rows | Gross Usage cost USD | Share of gross Usage cost |
|---|---:|---:|---:|
| ALLOCATED | 2,130 | 15.854914 | 97.49% |
| UNALLOCATED | 402 | 0.407751 | 2.51% |
| **Total** | **2,532** | **16.262665** | **100.00%** |

The primary allocation KPI is cost-weighted coverage rather than row-count coverage because a large number of low- or zero-cost billing rows can distort a row-based percentage.

## Business-facing showback

Athena query ID: `988fec74-263e-417f-b2a6-7036142210b7`

The showback groups gross Usage cost by:

`Project -> Environment -> CostCenter -> Owner -> ManagedBy -> AWS service`

### Allocated cost

| Project | Environment | CostCenter | Owner | ManagedBy | Service | Gross cost USD |
|---|---|---|---|---|---|---:|
| aws-platform | dev | platform-eng | inaam | terraform | AmazonEKS | 9.686884 |
| aws-platform | dev | platform-eng | inaam | terraform | AmazonEC2 | 6.166472 |
| aws-platform | dev | platform-eng | inaam | terraform | AmazonVPC | 0.001190 |
| aws-platform | bootstrap | platform-eng | inaam | terraform | AmazonS3 | 0.000320 |
| aws-platform | bootstrap | platform-eng | inaam | terraform | AmazonDynamoDB | 0.000048 |
| **Allocated total** | | | | | | **15.854914** |

### Unallocated cost

| Service | Gross cost USD |
|---|---:|
| AmazonVPC | 0.343704 |
| AWSCostExplorer | 0.060000 |
| AmazonS3 | 0.002097 |
| AmazonAthena | 0.001950 |
| **Unallocated total** | **0.407751** |

Unallocated spend is surfaced explicitly rather than being silently discarded or assigned to a project without evidence.

The largest unallocated category is AmazonVPC. A separate drill-down query is included in `sql/cur-showback.sql` to identify the usage types responsible and determine whether the appropriate response is improved tagging, a shared-cost allocation rule or acceptance as an unallocated service charge.

## Reconciliation control

Athena query ID: `e3b85186-153b-4763-97a4-94aa6276c67b`

| Metric | USD |
|---|---:|
| Raw CUR gross Usage cost | 16.262665 |
| Showback gross Usage cost | 16.262665 |
| Reconciliation difference | 0.0000000000 |

The zero reconciliation difference confirms that the showback grouping did not drop or duplicate gross Usage cost.

## FinOps interpretation

This stage converts tagging from infrastructure metadata into an accountability view.

The result demonstrates:

- ownership dimensions can be extracted directly from CUR 2.0;
- 97.49% of gross Usage cost in the measured window is fully allocated across all five required dimensions;
- 2.51% remains explicitly unallocated and visible for remediation or shared-cost policy;
- showback totals reconcile exactly to raw CUR gross Usage cost;
- credits remain separate from the gross economic-cost allocation view.

## Interview summary

A concise explanation is:

> I activated and propagated five cost-allocation tags, then used CUR 2.0 and Athena to build a showback grouped by project, environment, cost centre, owner and management source. For the controlled August window, 97.49% of gross Usage cost was fully allocated and 2.51% remained unallocated. I kept the unallocated bucket visible and reconciled the showback back to raw CUR, with a zero difference, so the report is both accountable and financially controlled.

## Next control

Drill into the remaining 2.51% unallocated cost by service and usage type, then decide whether each item should be:

- fixed through tagging;
- allocated through an explicit shared-cost rule; or
- retained as genuinely unallocated/account-level spend.
