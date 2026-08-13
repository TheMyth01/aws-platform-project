# FinOps Optimisation Register

This register separates implemented controls, measured optimisation results and future opportunities.

## Status legend

- **IMPLEMENTED**: configuration or operating control exists and is evidenced.
- **MEASURED**: effect or cost is present in captured AWS billing data.
- **DESIGNED**: proposed change not yet implemented.
- **MODELLED**: calculated scenario, not realised saving.

## Implemented and measured controls

| Control | Status | Evidence | FinOps purpose |
|---|---|---|---|
| Verified teardown of non-production stack | IMPLEMENTED | `docs/week-5-cost-control-teardown.md` | Prevent fixed platform resources continuing to charge after testing |
| Five project cost-allocation tags | IMPLEMENTED | `docs/tagging-strategy.md`, `docs/evidence/` | Improve allocation and ownership visibility |
| Historical cost-allocation tag backfill | IMPLEMENTED | `docs/evidence/cost-allocation-tag-activation-and-backfill-2026-08-07.md` | Improve historic billing analysis |
| EKS worker instance, EBS and ENI tag propagation | IMPLEMENTED | `terraform/modules/eks/main.tf` | Reduce unallocated infrastructure spend |
| AWS Cost Explorer analysis | MEASURED | `docs/cost-analysis.md`, `docs/evidence/` | Identify actual cost drivers |
| CUR 2.0 / Athena billing analysis | MEASURED / OPERATIONAL | `docs/evidence/eks-upgrade-run2-2026-08-12.md` | Hourly and usage-type-level cost analysis |
| Project AWS Budget | IMPLEMENTED - TERRAFORM MANAGED | `terraform/envs/finops/` | Alert on project cost thresholds |
| Cost Anomaly Detection monitor | IMPLEMENTED - TERRAFORM MANAGED | `terraform/envs/finops/` | Detect unexpected project spend |
| Daily anomaly subscription | IMPLEMENTED - TERRAFORM MANAGED | `terraform/envs/finops/` | Deliver anomaly notifications |
| EKS 1.33 to 1.34 lifecycle optimisation | MEASURED | `docs/evidence/eks-upgrade-run2-2026-08-12.md` | Remove extended-support cost exposure |

## Controlled optimisation results

### EKS lifecycle optimisation

Baseline #1 used Kubernetes 1.33.

Measured EKS rate:

**approximately $0.60/hour**

Run #2 used Kubernetes 1.34 with the same worker count, NAT count and VPC architecture.

Measured EKS rate:

**approximately $0.10/hour**

Measured EKS control-plane cost reduction:

**83.33%**

Normalised gross core infrastructure cost fell from approximately **$0.7666 to $0.2714 per environment-hour**, an observed reduction of approximately **64.6%**.

The EKS percentage is the primary causal result because the Kubernetes version was the isolated experiment variable.

## Optimisation backlog

| Priority | Opportunity | Status | Why it matters | Trade-off / limitation | Next evidence required |
|---:|---|---|---|---|---|
| 1 | Single NAT Gateway for dev | DESIGNED - NEXT EXPERIMENT | NAT fixed cost remains material | Removes independent AZ egress path and may introduce cross-AZ traffic | Controlled Run #3 using EKS 1.34 |
| 2 | Tag-aware Athena showback | DESIGNED | Converts allocation metadata into business-facing cost visibility | Depends on billing tag coverage | Athena allocation query and output |
| 3 | CUR 2.0 / Athena pipeline as IaC | DESIGNED | Makes the operational billing pipeline reproducible | Requires additional Terraform design | Terraform code and validation |
| 4 | 730-hour baseline model | MODELLED - NOT YET PUBLISHED | Supports monthly decision scenarios | Must not be confused with realised spend | Reconciled measured rates |
| 5 | Spot worker nodes for non-prod | DESIGNED | May reduce worker compute cost | Interruptible capacity; compute is currently a smaller cost driver | Controlled pricing / workload test |
| 6 | VPC endpoints for ECR/S3 | DESIGNED | May reduce NAT processing on sufficiently high private-service traffic | Interface endpoint hourly charges may exceed savings at low traffic | Break-even analysis |
| 7 | Worker rightsizing / autoscaling | DESIGNED | Useful if compute becomes material | Current measured platform fixed costs dominate | Utilisation evidence |

## Prioritisation principle

Optimisations are ranked from measured billing data rather than generic cloud-cost recommendations.

The project first identified the largest cost drivers, then changed one architecture variable at a time and measured the result.

## Decision log

| Date | Decision | Status | Rationale |
|---|---|---|---|
| 2026-04-24 | Tear down the validated dev environment after testing | IMPLEMENTED | Avoid unnecessary fixed non-production platform cost |
| 2026-08-07 | Keep implemented, measured, designed and modelled claims separate | IMPLEMENTED | Maintain evidence-led documentation |
| 2026-08-10 | Run controlled EKS 1.33 baseline | MEASURED | Establish a clean CUR 2.0 baseline |
| 2026-08-12 | Upgrade controlled run to EKS 1.34 | MEASURED | Test removal of the extended-support surcharge |
| 2026-08-12 | Keep two NAT Gateways during Run #2 | IMPLEMENTED EXPERIMENT CONTROL | Isolate EKS version rather than combining optimisations |
| Next | Test two NAT Gateways versus one | DESIGNED | Measure cost/resilience trade-off independently |