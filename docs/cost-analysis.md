# FinOps Cost Analysis

## Status

**MEASURED:** April 2026 actual usage analysis is supported by Cost Explorer CSV evidence under `docs/evidence/`.

**MODELLED:** Monthly baselines and optimisation scenarios are not yet published here. They will be added only after pricing and/or CUR 2.0 reconciliation is complete.

## Scope

AWS Cost Explorer analysis for the platform build period:

- Date range: 20 April 2026 to 30 April 2026
- Metric: Unblended cost
- Charge type: Usage
- Granularity: Daily
- Initial grouping: Service
- Drill-down grouping: Usage Type
- Workload region: eu-west-2
- Currency: USD

Raw evidence is stored in `docs/evidence/`.

## Measured total

Total unblended Usage cost for the period was:

**$1.9304346123**

This was a short-lived development and validation environment. It included failed and partial build periods and was intentionally torn down after testing. The measured total must not be compared directly with a healthy 730-hour monthly baseline as though they were equivalent operating periods.

## Measured service breakdown

| Service | Cost (USD) | Share |
|---|---:|---:|
| Elastic Container Service for Kubernetes (EKS) | 1.0301776140 | 53.37% |
| EC2-Other | 0.7933642553 | 41.10% |
| EC2-Instances | 0.0446604532 | 2.31% |
| VPC | 0.0347277850 | 1.80% |
| Elastic Load Balancing | 0.0264615111 | 1.37% |
| S3 | 0.0005691823 | 0.03% |
| ECR | 0.0003863993 | 0.02% |
| Other measured services | 0.0000874121 | <0.01% |
| **Total** | **1.9304346123** | **100%** |

Source: `docs/evidence/cost-explorer-service-2026-04-20_to_2026-04-30.csv`.

## EC2-Other drill-down

The second-largest service category was investigated by Usage Type.

| Component | Cost (USD) | Share of EC2-Other |
|---|---:|---:|
| NAT Gateway hourly | 0.7000000000 | 88.23% |
| NAT Gateway data processing | 0.0868704034 | 10.95% |
| EBS gp3 | 0.0064938519 | 0.82% |
| Other transfer lines | 0.0000000000 | 0.00% |
| **Total EC2-Other** | **0.7933642553** | **100%** |

NAT-related charges therefore represented more than 99% of the EC2-Other category.

Source: `docs/evidence/cost-explorer-ec2-other-usage-type-2026-04-20_to_2026-04-30.csv`.

## EC2 compute drill-down

| Instance usage type | Cost (USD) | Share of EC2 compute |
|---|---:|---:|
| t3.small | 0.0308700980 | 69.12% |
| t3.micro | 0.0137896098 | 30.88% |
| **Total EC2 compute** | **0.0446597078** | **~100%** |

The full EC2-Instances Cost Explorer export totals $0.0446604532 because it also includes a very small data-transfer line.

This aligns with the project history: the environment first used `t3.micro` and later moved to `t3.small` after pod-capacity constraints were encountered.

Source: `docs/evidence/cost-explorer-ec2-instances-usage-type-2026-04-20_to_2026-04-30.csv`.

## VPC drill-down

| Usage type | Cost (USD) |
|---|---:|
| Public IPv4 in use | 0.032291665 |
| Public IPv4 idle | 0.002436120 |
| **Total VPC** | **0.034727785** |

The idle IPv4 line is small but useful operational evidence: allocated public IPv4 resources can continue charging when not attached or useful, so teardown verification matters.

Source: `docs/evidence/cost-explorer-vpc-usage-type-2026-04-20_to_2026-04-30.csv`.

## Findings

### 1. Fixed platform costs dominated the observed spend

EKS control-plane and NAT-related charges were the largest measured cost drivers. EC2 worker compute was only about 2.3% of total usage cost in this period.

This means a generic optimisation approach focused first on EC2 rightsizing would have targeted a small part of this specific bill.

### 2. The largest practical lever was environment existence and duration

The EKS control plane and NAT Gateways charge while provisioned whether or not the sample application is producing business value. For a non-production portfolio environment, verified teardown is therefore a high-value control.

### 3. NAT architecture deserves separate treatment from compute

Two NAT Gateways were deliberately used to build and understand a multi-AZ pattern. For production this resilience can be appropriate. For dev, a single NAT Gateway may be an acceptable cost/resilience trade-off and will be tested as a separate optimisation scenario.

### 4. Measured and modelled figures must remain separate

The $1.9304346123 figure is actual AWS usage from a short-lived build period. A future 730-hour baseline will be a model, not realised spend. No percentage saving will be claimed until the comparison basis is explicit and defensible.

## Known limitations

- Cost allocation tag activation was not evidenced before the April run.
- Managed EKS node-group tags do not automatically prove tag coverage on underlying EC2 instances, volumes and ENIs; this will be fixed and measured during the next instrumented run.
- No CUR 2.0/Data Export evidence exists for April yet.
- No Athena reconciliation has yet been performed.
- The April period includes failed/partial provisioning and is not a clean steady-state workload sample.

## Next analytical steps

1. Activate the five cost allocation tags and capture CLI evidence.
2. Request historical tag backfill for April if the account is eligible.
3. Implement CUR 2.0/Data Exports to S3 in Terraform.
4. Request historical CUR 2.0 backfill if available.
5. Fix node-level tag propagation.
6. Run a controlled instrumented baseline session with precise start/end timestamps.
7. Reconcile rate x quantity to actual cost in Athena.
8. Build a 730-hour model from evidenced rates.
9. Compare explicitly labelled optimisation scenarios with trade-offs.
