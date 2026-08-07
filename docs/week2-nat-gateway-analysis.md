# Week 2 - NAT Gateway Architecture and Cost Review

**Environment:** dev  
**Original architecture decision date:** 2026-04-21  
**Original decision:** two NAT Gateways to build the multi-AZ pattern, with aggressive destroy discipline

## Status

- Two-NAT architecture: **IMPLEMENTED**
- April NAT usage: **MEASURED**
- Single-NAT alternative: **DESIGNED**, not yet tested
- Monthly always-on cost: **MODELLED later**, not published here until reconciled pricing is available

## Why two NAT Gateways were used

The dev VPC was intentionally built with one NAT Gateway per Availability Zone so the project would demonstrate the multi-AZ routing pattern rather than only the cheapest possible lab configuration.

The trade-off was explicit:

- more resilient egress design;
- higher fixed hourly cost;
- cost controlled operationally by destroying the environment after active sessions.

Terraform exposes `single_nat_gateway`, so the same module can later test a cheaper non-production design without rewriting the networking module.

## Implemented routing pattern

- NAT Gateway 1 in the eu-west-2a public subnet
- NAT Gateway 2 in the eu-west-2b public subnet
- private route tables use the NAT path configured by the module
- database-tier route tables follow the same per-AZ pattern

See `terraform/modules/vpc/` and `terraform/envs/dev/main.tf`.

## Measured April 2026 NAT cost

Cost Explorer was filtered to:

- 20-30 April 2026
- Unblended cost
- Charge type = Usage
- Service = EC2-Other
- Group by Usage Type

Measured EC2-Other total: **$0.7933642553**.

Breakdown:

| Component | Measured cost (USD) |
|---|---:|
| NAT Gateway hourly | 0.7000000000 |
| NAT Gateway data processing | 0.0868704034 |
| EBS gp3 | 0.0064938519 |
| **EC2-Other total** | **0.7933642553** |

NAT-related charges therefore represented more than 99% of the EC2-Other category during the measured period.

Evidence: `docs/evidence/cost-explorer-ec2-other-usage-type-2026-04-20_to_2026-04-30.csv`.

## What changed after measuring the bill

The original architecture decision still makes sense for learning the HA pattern, but the optimisation priority is now data-led:

1. keep the two-NAT pattern as the baseline architecture to understand production-style resilience;
2. keep dev ephemeral so fixed charges do not continue when no work is happening;
3. test `single_nat_gateway = true` in a controlled future run;
4. compare the before/after cost and state the resilience trade-off;
5. evaluate VPC endpoints only after measuring whether NAT data-processing volume is high enough to justify their own hourly cost.

## Tagging correction

The original document claimed zero untagged spend was expected. That claim is withdrawn.

Terraform provider `default_tags` applies the five-tag strategy to supported resources, but managed EKS node-group tags do not by themselves prove the underlying worker EC2 instances, EBS volumes and ENIs carry the same allocation tags.

This gap will be fixed and measured during the next instrumented run. See `docs/tagging-strategy.md`.

## Production perspective

For a production workload, removing per-AZ NAT resilience requires a deliberate availability decision. The single-NAT configuration is therefore treated as a non-production optimisation experiment, not a blanket production recommendation.

For high private-service traffic volumes, VPC endpoints may reduce NAT data-processing charges, but the endpoint hourly cost must be included in the break-even analysis before calling it an optimisation.
