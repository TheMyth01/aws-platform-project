# FinOps Evidence Register

This directory stores raw evidence used by the FinOps analysis. Numbers in project documentation should be traceable to a file here or to separately documented AWS API/CLI output.

## April 2026 Cost Explorer evidence

Cost Explorer settings used for the measured analysis:

- Date range: 20 April 2026 to 30 April 2026
- Metric: Unblended cost
- Charge type: Usage
- Granularity: Daily
- Region context: eu-west-2 workload

Files:

- `cost-explorer-service-2026-04-20_to_2026-04-30.csv` - grouped by Service
- `cost-explorer-ec2-other-usage-type-2026-04-20_to_2026-04-30.csv` - EC2-Other filtered, grouped by Usage type
- `cost-explorer-ec2-instances-usage-type-2026-04-20_to_2026-04-30.csv` - EC2-Instances filtered, grouped by Usage type
- `cost-explorer-vpc-usage-type-2026-04-20_to_2026-04-30.csv` - VPC filtered, grouped by Usage type

## Cost allocation tag evidence

- `cost-allocation-tags-pre-activation-2026-08-07.csv` - AWS Billing export before activation of the five project cost allocation tags
- `cost-allocation-tag-activation-and-backfill-2026-08-07.md` - CLI evidence showing activation of `Project`, `Environment`, `Owner`, `CostCenter`, and `ManagedBy`, plus successful historical backfill from 1 April 2026

## August 2026 controlled experiment evidence

- `baseline-run-2026-08-10_to_2026-08-11.txt` - controlled EKS 1.33 baseline deployment evidence, including workers, tags and NAT Gateways
- `run2-timestamps-2026-08-12.txt` - deploy, health-check and destroy timestamps for Run #2
- `eks-upgrade-run2-2026-08-12.md` - CUR 2.0 / Athena measured comparison showing removal of the EKS extended-support surcharge and the measured 83.33% EKS control-plane cost reduction
- `run3-timestamps-2026-08-13_to_2026-08-14.txt` - deploy, health-check, pre-destroy and destroy timestamps for Run #3
- `single-nat-run3-2026-08-13_to_2026-08-14.md` - CUR 2.0 / Athena measured comparison of two NAT Gateways versus one, including fixed networking savings and resilience trade-offs
## Evidence rules

- **MEASURED** means the figure is present in captured AWS output.
- **MODELLED** means the figure is calculated from documented assumptions or pricing and is not realised spend.
- **IMPLEMENTED** means code/configuration exists and is supported by repository or AWS-side evidence.
- **DESIGNED** means a target-state control has been specified but not yet implemented.

Do not overwrite historical evidence after AWS backfill changes the billing views. Capture any backfilled version as a new dated file so before/after behaviour remains visible.
