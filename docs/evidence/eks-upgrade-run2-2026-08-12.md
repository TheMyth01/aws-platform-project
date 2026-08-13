# Controlled Optimisation Run #2 - EKS Extended Support Removal

## Experiment

Run #2 tested one controlled infrastructure change:

- Baseline: Amazon EKS Kubernetes 1.33
- Optimised run: Amazon EKS Kubernetes 1.34
- Worker nodes: unchanged at 2 x t3.small
- NAT Gateways: unchanged at 2
- VPC architecture: unchanged
- Tagging configuration: unchanged

The purpose was to isolate the cost effect of moving the EKS cluster from a Kubernetes version in extended support to a version in standard support.

## Run timestamps

- Deploy start: 2026-08-12 00:42:10 +01:00
- Health check: 2026-08-12 00:53:35 +01:00
- Destroy start: 2026-08-12 11:51:47 +01:00

Terraform apply completed with 38 resources added.

The deployed environment was verified with:

- EKS cluster ACTIVE
- Kubernetes version 1.34
- managed node group ACTIVE
- desired worker count 2
- two NAT Gateways available

Terraform destroy subsequently completed with 38 resources destroyed.

## CUR 2.0 / Athena measured result

Amazon EKS usage for Run #2:

| Usage type | Usage hours | Gross cost USD |
|---|---:|---:|
| EUW2-AmazonEKS-Hours:perCluster | 11.174742 | 1.117474 |

No `EUW2-AmazonEKS-Hours:extendedSupport` Usage line appeared in the Run #2 CUR data.

Measured effective EKS control-plane rate:

$1.117474 / 11.174742 hours = approximately $0.10 per hour.

## Baseline comparison

Baseline #1 used EKS Kubernetes 1.33.

Measured baseline EKS usage:

| Component | Usage hours | Gross cost USD |
|---|---:|---:|
| Standard EKS control plane | 9.768626 | 0.976863 |
| EKS extended-support surcharge | 9.768626 | 4.884313 |
| Total EKS | 9.768626 | 5.861176 |

Measured baseline EKS effective rate:

approximately $0.60 per hour.

Run #2 EKS effective rate:

approximately $0.10 per hour.

## Measured optimisation result

The upgrade from EKS 1.33 to EKS 1.34 removed the measured $0.50/hour extended-support surcharge.

EKS control-plane cost therefore changed from:

- Baseline: approximately $0.60/hour
- Run #2: approximately $0.10/hour

Measured EKS control-plane cost reduction:

**83.33%**

Normalised to the baseline duration of 9.768626 hours:

- Baseline EKS cost: $5.861176
- EKS 1.34 equivalent cost: $0.976863
- Gross cost avoided: $4.884313

## Whole-stack comparison

Core infrastructure gross cost:

| Run | Gross cost USD | EKS hours | Cost per environment-hour |
|---|---:|---:|---:|
| Baseline #1 | 7.488387 | 9.768626 | 0.766575 |
| Run #2 | 3.032617 | 11.174742 | 0.271381 |

Normalised gross core infrastructure cost fell by approximately:

**64.6% per environment-hour**

The runs had different durations, so raw total cost is not used as the primary comparison.

The 83.33% EKS reduction is the cleanest causal result because EKS version was the deliberately isolated change.

## Credits

AWS credits reduced the actual cash charge during the experiment.

Credits are reported separately from gross cost because credits do not remove the underlying economic cost of operating the architecture.

Run #2 core infrastructure:

- Gross cost: $3.032617
- Credits: approximately -$2.876697
- Net cash cost after credits: approximately $0.155920

The FinOps optimisation assessment therefore uses gross cost rather than net post-credit cost.

## Conclusion

The controlled experiment demonstrated that identifying lifecycle-related EKS charges in CUR 2.0 and upgrading from Kubernetes 1.33 to 1.34 removed the extended-support surcharge.

This was a measured infrastructure optimisation rather than a modelled saving.
