# FinOps Optimisation Register

This register separates controls already implemented from opportunities that are only designed or modelled.

## Status legend

- **IMPLEMENTED**: configuration or operating control exists and is evidenced.
- **MEASURED**: effect or cost is present in captured AWS data.
- **DESIGNED**: proposed change not yet implemented.
- **MODELLED**: calculated scenario, not realised saving.

## Implemented controls

| Control | Status | Evidence | FinOps purpose |
|---|---|---|---|
| Verified teardown of non-production stack | IMPLEMENTED | `docs/week-5-cost-control-teardown.md` | Prevent fixed EKS, NAT, ALB, IPv4 and compute charges from continuing after testing |
| Five-tag Terraform `default_tags` strategy | IMPLEMENTED with known coverage gap | `terraform/envs/dev/providers.tf`, `docs/tagging-strategy.md` | Establish allocation metadata at provisioning |
| ECR lifecycle policy | IMPLEMENTED | `terraform/modules/ecr/main.tf` | Cap image growth and expire old untagged images |
| Cost Explorer drill-down by service and usage type | MEASURED | `docs/evidence/`, `docs/cost-analysis.md` | Identify actual cost drivers before prioritising optimisations |

## Designed optimisation backlog

| Priority | Opportunity | Status | Why it matters | Trade-off / limitation | Next evidence required |
|---:|---|---|---|---|---|
| 1 | Ephemeral dev operation | IMPLEMENTED operating practice; monthly saving not yet modelled from reconciled rates | Fixed platform components dominate this workload | Requires apply/destroy time and disciplined teardown | Build reconciled 730-hour baseline, then model controlled session schedule |
| 2 | Single NAT Gateway for dev | DESIGNED | NAT fixed cost was a major measured driver | Removes independent AZ egress path; may add cross-AZ traffic cost | Instrumented before/after run with same workload protocol |
| 3 | Cost allocation tag activation + historical backfill | DESIGNED | Terraform tags do not by themselves make tag dimensions available in billing analytics | Historical values only exist where resources had tags at the time | CLI output showing active tags and backfill result |
| 4 | Fix EKS worker resource tag propagation | DESIGNED | Managed node-group metadata does not prove tags exist on underlying EC2/EBS/ENI resources | Requires launch-template change and node-group replacement | Before/after unallocated-spend query from CUR 2.0 |
| 5 | CUR 2.0 / Data Exports to S3 | DESIGNED | Enables resource-level, hourly and tag-aware cost analysis | New pipeline and schema to manage | Terraform code, S3 output and Athena query results |
| 6 | AWS Budgets | DESIGNED | Detect forgotten always-on resources early | Thresholds need to be justified against baseline | Terraform + notification evidence |
| 7 | Cost Anomaly Detection | DESIGNED | Adds automated detection of unexpected spend | Requires history; low signal on a very ephemeral estate | Monitor/subscription configuration and observed output |
| 8 | Spot worker nodes for non-prod | DESIGNED | Reduces the compute portion of cost | Interruptible capacity; savings apply only to a small share of this stack's measured bill | Price/effective-rate evidence and controlled scenario |
| 9 | VPC endpoints for ECR/S3 | DESIGNED analysis only | Can reduce NAT data-processing on workloads with enough private-service traffic | Interface endpoints have their own hourly cost and may cost more at low volume | Break-even analysis from measured traffic and current prices |
| 10 | Node rightsizing / autoscaling | DESIGNED | Useful if future compute becomes material | Current measured EC2 compute share is small; pod density and network limits matter | Utilisation metrics and later workload data |

## Prioritisation principle

Optimisations are ranked from measured cost data rather than generic cloud-cost advice. In the April evidence, EKS and NAT dominated while EC2 worker compute was a small share. Therefore lifecycle and architecture controls come before aggressive compute optimisation for this specific workload.

## Decision log

| Date | Decision | Status | Rationale |
|---|---|---|---|
| 2026-04-24 | Tear down the validated dev environment after testing | IMPLEMENTED | Avoid paying fixed non-production platform cost while the environment had no active use |
| 2026-08-07 | Do not claim Phase 2 complete until billing controls and analysis are evidenced | IMPLEMENTED documentation decision | Restore a strict boundary between implemented, measured, designed and modelled claims |

Future decisions will be added only after the related control or experiment has been performed.
