# FinOps Evidence Register

This directory stores raw evidence used by the FinOps analysis. Numbers in project documentation should be traceable to a file here or to a separately documented AWS API/CLI output.

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

## Evidence rules

- **MEASURED** means the figure is present in captured AWS output.
- **MODELLED** means the figure is calculated from documented assumptions or pricing and is not realised spend.
- **IMPLEMENTED** means code/configuration exists and is supported by repository or AWS-side evidence.
- **DESIGNED** means a target-state control has been specified but not yet implemented.

Do not overwrite historical evidence after AWS backfill changes the billing views. Capture any backfilled version as a new dated file so before/after behaviour remains visible.
