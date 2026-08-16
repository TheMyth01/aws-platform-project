# FinOps Cost Analysis

## Status

**MEASURED:** April 2026 actual usage analysis is supported by Cost Explorer evidence.

**MEASURED:** August 2026 controlled baseline and optimisation runs are supported by CUR 2.0 / Athena results and captured infrastructure evidence.

**IMPLEMENTED:** project cost-allocation tags, EKS worker tag propagation, verified teardown, AWS Budget, Cost Anomaly Detection controls, reconciled tag-aware showback and the stable CUR 2.0 / Athena billing pipeline IaC have been implemented.

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

Two NAT Gateways were deliberately used to build and understand a multi-AZ pattern. Run #3 subsequently tested the dev environment with one NAT Gateway while retaining EKS 1.34, two t3.small workers and the same VPC/subnet structure. The controlled experiment measured the cost benefit while also documenting the loss of independent AZ-local egress and the presence of cross-AZ traffic.

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

- Baseline: approximately $0.766575 per EKS-metered environment-hour
- Run #2: approximately $0.271381 per EKS-metered environment-hour

This is an observed reduction of approximately **64.6%**.

The whole-stack result is secondary to the EKS comparison because NAT Gateway billing granularity and different run durations introduce some variation. The EKS rate change is the stronger causal result because the EKS version was the deliberately isolated variable.

### Credits

AWS credits reduced the cash charge during the experiments.

Gross economic cost and net cash cost are therefore reported separately. The optimisation assessment uses gross Usage cost because credits do not remove the underlying architecture cost.

Evidence:

- `docs/evidence/baseline-run-2026-08-10_to_2026-08-11.txt`
- `docs/evidence/eks-upgrade-run2-2026-08-12.md`
- `docs/evidence/run2-timestamps-2026-08-12.txt`

## August 2026 controlled NAT optimisation

Run #3 tested a second isolated infrastructure variable.

The environment retained:

- Amazon EKS Kubernetes 1.34;
- 2 x `t3.small` worker nodes;
- the same VPC and subnet structure;
- the same cost-allocation tagging configuration.

The intended experiment variable was NAT Gateway count:

- Run #2: 2 NAT Gateways
- Run #3: 1 NAT Gateway

### Run #3 measured values

CUR 2.0 / Athena measured:

| Component | Usage | Gross cost USD |
|---|---:|---:|
| EKS control plane | 27.076600 hours | 2.707660 |
| t3.small workers | 53.974445 hours | 1.273797 |
| NAT Gateway hours | 28.000000 hours | 1.400000 |
| NAT data processing | 0.501710 GB | 0.025086 |
| EBS gp3 | 1.451613 | 0.134710 |
| Public IPv4 in-use | 27.036666 hours | 0.135183 |
| Public IPv4 idle | 0.047223 hours | 0.000236 |
| **Core infrastructure total** | | **5.676672** |

Measured EKS rate remained approximately **$0.10/hour**, confirming the EKS lifecycle optimisation remained in place.

Normalised core infrastructure cost was approximately:

**$0.209652 per EKS-metered environment-hour**

Run #2 measured approximately:

**$0.271381 per EKS-metered environment-hour**

The observed normalised whole-stack reduction was therefore approximately:

**22.75%**

This whole-stack figure is secondary because the controlled runs had different durations and AWS hourly billing boundaries affect short-lived experiments.

### Fixed networking comparison

The measured AWS unit rates were:

- NAT Gateway: **$0.05 per NAT Gateway-hour**
- Public IPv4: approximately **$0.005 per address-hour**

The fixed architectural rate therefore changes from:

- two NAT Gateways plus two associated public IPv4 addresses: **$0.11/hour**
- one NAT Gateway plus one associated public IPv4 address: **$0.055/hour**

This represents a **50% reduction in the fixed NAT Gateway plus associated public IPv4 rate**.

This is the cleaner architectural result because NAT Gateway count was the deliberately isolated infrastructure variable.

### Engineering trade-off

CUR also recorded regional inter-AZ usage during Run #3:

- InterZone-Out: 0.255191
- InterZone-In: 0.267666

The corresponding unblended cost in this low-traffic experiment was $0.00.

The single-NAT design reduces fixed non-production cost but removes independent AZ-local outbound egress. Traffic originating in the other Availability Zone can also traverse AZ boundaries to use the shared NAT Gateway.

For production workloads, resilience requirements and higher traffic volumes may justify retaining a NAT Gateway per AZ.

### Modelled 730-hour scenario

Using the measured fixed-rate difference:

$0.11/hour - $0.055/hour = $0.055/hour

At 730 hours this equates to:

**$40.15/month**

This value is **MODELLED**, not realised AWS monthly spend.

Evidence:

- `docs/evidence/run3-timestamps-2026-08-13_to_2026-08-14.txt`
- `docs/evidence/single-nat-run3-2026-08-13_to_2026-08-14.md`

## August 2026 tag-aware showback

The CUR 2.0 `resource_tags` field is a map and exposes the five activated ownership dimensions as `user_project`, `user_environment`, `user_owner`, `user_cost_center` and `user_managed_by`.

For gross `Usage` cost from 10 to 15 August 2026:

| Allocation method | Gross cost USD | Interpretation |
|---|---:|---|
| DIRECTLY_ALLOCATED | 15.854914 | All five ownership dimensions populated in CUR |
| RULE_ALLOCATED | 0.343704 | NAT-associated public IPv4 Usage attributed from the controlled ENI/timeline evidence |
| UNALLOCATED | 0.064047 | Shared/account-level Cost Explorer, Athena and S3 overhead retained without forced allocation |
| **Total** | **16.262665** | **Fully reconciled to raw CUR Usage cost** |

Direct tag coverage was **97.49%** by gross Usage cost. Using the underlying measured cost values, direct plus evidence-based rule allocation produced approximately **99.61% attributable cost coverage**.

The rule allocation was added only after the public IPv4 Usage was drilled down to untagged network-interface rows whose timing matched the known controlled topology: two NAT Gateways in Baseline #1, two in Run #2 and one in Run #3. The rule is therefore explicitly scoped to this experiment and is not presented as a generic AWS allocation rule.

The remaining **$0.064047**, approximately **0.39%**, is kept visible as shared/unallocated account tooling spend rather than being assigned arbitrarily.

The enhanced showback reconciled to raw CUR gross Usage cost with a difference of **$0.0000000000**.

Evidence:

- `docs/evidence/tag-aware-showback-2026-08-10_to_2026-08-15.md`
- `sql/cur-showback.sql`

## August 2026 CUR 2.0 / Athena IaC adoption

The existing operational billing pipeline was brought under Terraform management as a brownfield adoption rather than rebuilt.

The stable Terraform scope now includes the existing billing S3 bucket, public-access block, ownership controls, SSE-S3 encryption configuration, delivery bucket policy, Glue catalog database and BCM Data Export. Historical billing data and the working export were preserved.

The live export uses Athena output. Because the native `hashicorp/aws` BCM Data Exports resource did not accept the live `ATHENA` output type, the export itself is represented with the official `hashicorp/awscc` provider while the remaining AWS resources continue to use `hashicorp/aws`.

After import, an older Cost Anomaly Detection monitor drift was identified and reconciled in configuration without applying a replacement. `terraform validate` succeeded and two consecutive `terraform plan` runs returned **no changes**.

Evidence:

- `terraform/envs/finops/billing-pipeline.tf`
- `docs/evidence/cur2-iac-adoption-2026-08-16.md`

## Known limitations

- The controlled runs had different durations, so raw total cost is not treated as a like-for-like comparison.
- NAT Gateway billing is hourly and can introduce billing-granularity differences between short experiments.
- The whole-stack percentage is therefore an observed normalised result rather than a claim that every component fell by the same percentage.
- AWS credits materially reduced cash cost, so gross Usage cost is used for optimisation analysis.
- The external Glue table is intentionally not frozen into Terraform because its CUR-derived schema can evolve independently of the stable billing infrastructure.
- The public IPv4 rule allocation is evidence-based and window-specific; it should not be reused for unrelated resources without equivalent attribution evidence.
- These are short-lived development experiments rather than a production utilisation sample.

## Next analytical steps

1. Document a shared FinOps tooling-cost policy for the remaining approximately 0.39% account-level overhead.
2. Extend the 730-hour model using reconciled measured EKS and networking rates while keeping it explicitly labelled as modelled.
3. Evaluate compute optimisation only if EC2 worker cost becomes materially significant.
