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

A row is treated as directly allocated only when all five ownership dimensions are populated.

## Cost-weighted direct allocation coverage

Athena query ID: `6c524d4c-b382-41ed-9597-c29c81634954`

| Allocation status | CUR rows | Gross Usage cost USD | Share of gross Usage cost |
|---|---:|---:|---:|
| ALLOCATED | 2,130 | 15.854914 | 97.49% |
| UNALLOCATED | 402 | 0.407751 | 2.51% |
| **Total** | **2,532** | **16.262665** | **100.00%** |

The primary allocation KPI is cost-weighted coverage rather than row-count coverage because a large number of low- or zero-cost billing rows can distort a row-based percentage.

## Business-facing direct-tag showback

Athena query ID: `988fec74-263e-417f-b2a6-7036142210b7`

The direct-tag showback groups gross Usage cost by:

`Project -> Environment -> CostCenter -> Owner -> ManagedBy -> AWS service`

### Directly allocated cost

| Project | Environment | CostCenter | Owner | ManagedBy | Service | Gross cost USD |
|---|---|---|---|---|---|---:|
| aws-platform | dev | platform-eng | inaam | terraform | AmazonEKS | 9.686884 |
| aws-platform | dev | platform-eng | inaam | terraform | AmazonEC2 | 6.166472 |
| aws-platform | dev | platform-eng | inaam | terraform | AmazonVPC | 0.001190 |
| aws-platform | bootstrap | platform-eng | inaam | terraform | AmazonS3 | 0.000320 |
| aws-platform | bootstrap | platform-eng | inaam | terraform | AmazonDynamoDB | 0.000048 |
| **Directly allocated total** | | | | | | **15.854914** |

### Initially unallocated cost

| Service | Gross cost USD |
|---|---:|
| AmazonVPC | 0.343704 |
| AWSCostExplorer | 0.060000 |
| AmazonS3 | 0.002097 |
| AmazonAthena | 0.001950 |
| **Initially unallocated total** | **0.407751** |

Unallocated spend was surfaced explicitly rather than silently discarded or assigned to a project without evidence.

## Direct showback reconciliation control

Athena query ID: `e3b85186-153b-4763-97a4-94aa6276c67b`

| Metric | USD |
|---|---:|
| Raw CUR gross Usage cost | 16.262665 |
| Direct-tag showback gross Usage cost | 16.262665 |
| Reconciliation difference | 0.0000000000 |

The zero reconciliation difference confirms that the grouping did not drop or duplicate gross Usage cost.

## Investigation of initially unallocated spend

Athena query ID: `249af3bc-8007-4409-ad70-8c7cbac0317a`

The $0.407751 initially unallocated amount was drilled down by service and usage type.

The largest item was:

- AmazonVPC `EUW2-PublicIPv4:InUseAddress`: **$0.343704** across 72 CUR rows.

The remaining material account/tooling items were:

- AWS Cost Explorer API requests: **$0.060000**;
- Amazon Athena data scanned: **$0.001950**;
- Amazon S3 requests/storage: approximately **$0.002097**.

The public IPv4 item therefore represented approximately 84% of the initially unallocated cost and warranted a resource-level investigation.

## Public IPv4 ENI evidence

Athena query ID: `c0c2e6d2-ff2b-4818-9c6d-5680e4ced21d`

The untagged public IPv4 Usage rows were associated with five network-interface resource IDs. Their CUR timing aligned with the known controlled experiment topology:

| Controlled run | Untagged public IPv4 ENIs | Approximate measured IPv4 hours per ENI |
|---|---:|---:|
| Baseline #1 | 2 | ~9.717 |
| Run #2 | 2 | 11.135 |
| Run #3 | 1 | 27.036666 |

This matches the experiment sequence of two NAT Gateways in Baseline #1, two NAT Gateways in Run #2, and one NAT Gateway in Run #3.

The evidence supports treating the $0.343704 public IPv4 Usage as attributable to the `aws-platform` dev networking architecture for this controlled experiment window.

This is explicitly an **evidence-based allocation rule for this measured window**, not a blanket rule that every untagged public IPv4 charge in AWS should be assigned to this project.

## Final allocation-method coverage

Athena query ID: `34401f85-afae-4ff3-b2f7-89e2bea5973d`

| Allocation method | CUR rows | Gross Usage cost USD | Reported share |
|---|---:|---:|---:|
| DIRECTLY_ALLOCATED | 2,130 | 15.854914 | 97.49% |
| RULE_ALLOCATED | 72 | 0.343704 | 2.11% |
| UNALLOCATED | 330 | 0.064047 | 0.39% |
| **Total** | **2,532** | **16.262665** | **100% before display rounding** |

Using the underlying cost values, directly allocated plus evidence-based rule-allocated spend equals **$16.198618**, or approximately **99.61% attributable cost coverage**.

The remaining **$0.064047**, approximately **0.39%**, is retained as unallocated/shared account tooling rather than being forced onto the application without evidence.

The displayed category percentages are independently rounded to two decimal places, so their displayed sum may differ slightly from 100%.

## Enhanced reconciliation control

Athena query ID: `8e0a7c77-3af7-496f-9cd1-5a1b12b21fe5`

| Metric | USD |
|---|---:|
| Raw CUR gross Usage cost | 16.262665 |
| Enhanced showback gross Usage cost | 16.262665 |
| Reconciliation difference | 0.0000000000 |

The enhanced allocation treatment therefore remains fully reconciled to raw CUR gross Usage cost.

## FinOps interpretation

This stage converts tagging from infrastructure metadata into an accountability view and demonstrates a controlled treatment for shared or indirectly attributable cost.

The result demonstrates:

- ownership dimensions can be extracted directly from CUR 2.0;
- 97.49% of gross Usage cost is directly allocated across all five required dimensions;
- a further 2.11% is attributable through a documented, evidence-based rule specific to the controlled NAT/public-IPv4 experiment;
- effective attributable cost coverage is approximately 99.61%;
- approximately 0.39% remains explicitly unallocated/shared rather than being arbitrarily forced onto a workload;
- showback totals reconcile exactly to raw CUR gross Usage cost;
- credits remain separate from the gross economic-cost allocation view.

## Interview summary

A concise explanation is:

> I activated and propagated five cost-allocation tags, then used CUR 2.0 and Athena to build a showback grouped by project, environment, cost centre, owner and management source. Direct tag coverage was 97.49% by gross Usage cost. I investigated the remaining spend rather than forcing allocation, and found that the largest gap was public IPv4 Usage recorded against untagged network interfaces whose timing reconciled to the known NAT topology of the three controlled runs. I kept that as a separate evidence-based rule allocation, which increased attributable coverage to approximately 99.61%, while retaining genuine shared tooling costs as unallocated. Both the direct and enhanced showback reconcile exactly to raw CUR with a zero difference.

## Next control

The next major project control is to codify the operational CUR 2.0 / Athena billing pipeline in infrastructure as code so the reporting foundation is reproducible as well as operational.
