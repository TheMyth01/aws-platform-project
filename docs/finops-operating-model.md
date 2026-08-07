# FinOps Operating Model: AWS Platform Project

This document describes the operating model for the project and clearly separates controls already implemented from target-state controls that are still being built.

## Status legend

- **IMPLEMENTED**: built/configured and supported by repository or AWS-side evidence.
- **MEASURED**: supported by captured billing data.
- **DESIGNED**: target-state control not yet implemented.
- **MODELLED**: scenario calculation, not realised spend.

## Inform

### Five-tag provisioning policy - IMPLEMENTED with known coverage gap

The Terraform AWS provider applies these default tags:

| Tag | Purpose |
|---|---|
| Project | Groups spend to a deliverable or product |
| Environment | Supports lifecycle and environment-level analysis |
| Owner | Identifies the accountable person |
| CostCenter | Provides a business allocation dimension |
| ManagedBy | Records the provisioning/management mechanism |

Terraform source: `terraform/envs/dev/providers.tf`.

Known limitation: provider `default_tags` on the managed EKS node-group resource do not by themselves prove that underlying EC2 instances, EBS volumes and ENIs receive the same tags. The next implementation stage will add and verify worker-resource tag propagation.

Cost allocation tag activation in AWS Billing is **DESIGNED / TO VERIFY**. It must not be treated as implemented until CLI or console evidence confirms all five keys are Active.

### Cost visibility - MEASURED

AWS Cost Explorer data for 20-30 April 2026 has been captured and committed under `docs/evidence/`. The analysis identifies EKS and NAT-related charges as the largest measured cost drivers during the project build period.

See `docs/cost-analysis.md`.

### Showback - DESIGNED

The target showback report will present:

- total cost;
- allocation coverage and explicit unallocated spend;
- cost by Project, Environment, CostCenter and Owner;
- cost by service within the dev environment;
- daily trend;
- cost per cluster-hour / active session where supported by data;
- variance explanation and actions.

This will be generated from CUR 2.0/Data Exports queried with Athena. No showback is currently claimed as implemented.

## Optimize

### Optimisation register - IMPLEMENTED as a governance artefact

Opportunities are tracked in `docs/optimisation-register.md` with explicit status, rationale, trade-offs and required evidence.

The register deliberately separates:

- controls already implemented;
- measured findings;
- designed changes;
- modelled scenarios.

No modelled saving is described as realised.

## Operate

### Verified teardown - IMPLEMENTED

Non-production infrastructure is torn down after active development/validation sessions and the teardown is verified rather than assumed.

The evidence includes checks for:

- Terraform state;
- EKS clusters;
- load balancers;
- NAT Gateways;
- Elastic IPs;
- EC2 worker nodes.

See `docs/week-5-cost-control-teardown.md`.

### AWS Budgets - DESIGNED

Target implementation:

- account/project monthly budget;
- forecasted threshold notifications;
- actual-spend threshold notifications;
- low-cost/zero-spend control for an environment expected to be torn down.

Budgets will be implemented in Terraform before the next instrumented run. No budget is currently claimed as deployed.

### Cost Anomaly Detection - DESIGNED

Target implementation:

- service-dimensional anomaly monitor;
- anomaly subscription;
- low absolute impact threshold suitable for a personal lab account;
- documented limitation that an ephemeral estate provides little historical baseline.

No anomaly monitor is currently claimed as deployed.

### Decision log - IMPLEMENTED as a process

Material cost decisions are recorded in `docs/optimisation-register.md` with date, status and rationale. Future entries will be added when an experiment or implementation has actually occurred.

## Target operating cadence

Once the instrumentation exists, the intended cadence is:

1. **Inform**: refresh cost data, measure allocation coverage, review service/resource drivers.
2. **Optimize**: rank opportunities by measured value, effort and risk.
3. **Operate**: implement approved controls, monitor budgets/anomalies, record outcomes and decisions.
4. Repeat with improved evidence.

The operating model is intentionally evidence-led: a control moves from DESIGNED to IMPLEMENTED only after it exists and can be verified.
