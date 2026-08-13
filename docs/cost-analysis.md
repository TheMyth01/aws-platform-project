# FinOps Cost Analysis

## Status

**MEASURED:** April 2026 actual usage analysis is supported by Cost Explorer evidence.

**MEASURED:** August 2026 controlled baseline and optimisation runs are supported by CUR 2.0 / Athena results and captured infrastructure evidence.

**IMPLEMENTED:** project cost-allocation tags, EKS worker tag propagation, verified teardown, AWS Budget and Cost Anomaly Detection controls have been implemented.

**MODELLED:** future monthly or 730-hour scenarios remain separate from realised AWS spend.
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

## August 2026 controlled EKS optimisation

A controlled baseline and optimisation run were performed to test one specific cost variable.

### Baseline #1 - EKS 1.33

Measured CUR 2.0 values:

| Component | Usage hours | Gross cost USD |
|---|---:|---:|
| EKS standard control plane | 9.768626 | 0.976863 |
| EKS extended support | 9.768626 | 4.884313 |
| Total EKS | 9.768626 | 5.861176 |

Effective EKS rate: approximately **$0.60/hour**.

Core infrastructure gross cost was **$7.488387**.

### Run #2 - EKS 1.34

The architecture retained:

- 2 x `t3.small` worker nodes;
- 2 NAT Gateways;
- the same VPC architecture;
- the same tagging configuration.

The only intended experiment variable was the EKS Kubernetes version.

Measured CUR 2.0 values:

| Usage type | Usage hours | Gross cost USD |
|---|---:|---:|
| EUW2-AmazonEKS-Hours:perCluster | 11.174742 | 1.117474 |

No `EUW2-AmazonEKS-Hours:extendedSupport` Usage row was present.

Effective EKS rate: approximately **$0.10/hour**.

Core infrastructure gross cost was **$3.032617**.

### Measured result

The measured EKS control-plane rate changed from approximately:

**$0.60/hour -> $0.10/hour**

This is an **83.33% reduction in EKS control-plane cost**.

Normalised to the baseline runtime, the measured gross EKS cost avoided was **$4.884313**.

Whole-stack normalised gross cost changed from:

- Baseline: approximately $0.766575 per environment-hour
- Run #2: approximately $0.271381 per environment-hour

This is an observed reduction of approximately **64.6%**.

The whole-stack result is secondary to the EKS comparison because NAT Gateway billing granularity and different run durations introduce some variation. The EKS rate change is the stronger causal result because the EKS version was the deliberately isolated variable.

### Credits

AWS credits reduced the cash charge during the experiments.

Gross economic cost and net cash cost are therefore reported separately. The optimisation assessment uses gross Usage cost because credits do not remove the underlying architecture cost.

Evidence:

- `docs/evidence/baseline-run-2026-08-10_to_2026-08-11.txt`
- `docs/evidence/eks-upgrade-run2-2026-08-12.md`
- `docs/evidence/run2-timestamps-2026-08-12.txt`

## Known limitations

- The controlled runs had different durations, so raw total cost is not treated as a like-for-like comparison.
- NAT Gateway billing is hourly and can introduce billing-granularity differences between short experiments.
- The whole-stack percentage is therefore an observed normalised result rather than a claim that every component fell by the same percentage.
- AWS credits materially reduced cash cost, so gross Usage cost is used for optimisation analysis.
- The CUR 2.0 / Athena pipeline is operational, but the Terraform under `terraform/envs/finops/` currently manages the project Budget and Cost Anomaly Detection controls rather than the billing export pipeline itself.
- These are short-lived development experiments rather than a production utilisation sample.

## Next analytical steps

1. Run the controlled single-NAT experiment while retaining EKS 1.34 and the same worker configuration.
2. Measure NAT Gateway fixed-cost reduction and document the resilience trade-off.
3. Produce a tag-aware Athena showback query.
4. Codify the operational CUR 2.0 / Athena billing pipeline in infrastructure as code.
5. Build a 730-hour model using reconciled measured rates and label it explicitly as modelled.
6. Evaluate compute optimisation only if EC2 worker cost becomes materially significant.