# AWS Platform Project

Production-style AWS platform built end to end with Terraform and Amazon EKS, then analysed as a FinOps case study using measured AWS Cost Explorer data.

## Recruiter Summary

This project demonstrates practical cloud engineering experience across Terraform, AWS networking, EKS, ECR, Kubernetes, ALB Ingress, IAM/IRSA, Helm, troubleshooting, cost visibility and FinOps controls.

The platform was provisioned, a containerised application was deployed to EKS and exposed through an AWS Application Load Balancer, the live endpoint was validated, real deployment failures were debugged, and the environment was then safely torn down to stop unnecessary non-production spend.

## Status Legend

- **IMPLEMENTED**: built or configured and supported by code or captured evidence in this repository.
- **MEASURED**: derived from captured AWS billing data committed under `docs/evidence/`.
- **DESIGNED**: target-state control or optimisation that has not yet been implemented.
- **MODELLED**: analytical scenario, clearly separated from realised AWS spend.

## Current Status

- **Phase 1 - Platform build: COMPLETE.**
- **Phase 2 - FinOps implementation and controlled optimisation: IN PROGRESS, WITH MEASURED RESULTS.**

The project now includes historical Cost Explorer analysis and controlled CUR 2.0 / Athena experiments.

A controlled baseline using EKS Kubernetes 1.33 measured an EKS control-plane rate of approximately **$0.60/hour**, including a **$0.50/hour extended-support surcharge**.

A second controlled run changed only the EKS version to Kubernetes 1.34 while retaining two `t3.small` workers, two NAT Gateways and the same VPC architecture. CUR 2.0 showed no extended-support Usage line and measured an EKS control-plane rate of approximately **$0.10/hour**.

This produced a measured **83.33% reduction in EKS control-plane cost**.

Normalised gross core infrastructure cost changed from approximately **$0.7666 to $0.2714 per environment-hour**, an observed reduction of approximately **64.6%**. The EKS result is the cleaner causal comparison because EKS version was the isolated variable.

Additional implemented FinOps controls include:

- activated project cost-allocation tags with historical backfill;
- launch-template tag propagation to EKS worker instances, volumes and network interfaces;
- CUR 2.0 billing analysis through Amazon Athena;
- a project-scoped AWS Budget managed through Terraform;
- a project-scoped Cost Anomaly Detection monitor and daily subscription managed through Terraform;
- verified teardown discipline for non-production infrastructure.

See:

- `docs/cost-analysis.md`
- `docs/optimisation-register.md`
- `docs/finops-operating-model.md`
- `docs/tagging-strategy.md`
- `docs/evidence/`

## Architecture Overview

```text
User
  |
  v
AWS Application Load Balancer
  |
  v
Kubernetes Ingress
  |
  v
Kubernetes Service
  |
  v
EKS Pods running the containerised app
  |
  v
Image pulled from Amazon ECR
```

Terraform manages the AWS infrastructure, including the VPC, subnets, route tables, NAT Gateways, EKS cluster, managed node group, ECR repository, IAM roles and IRSA setup.

## What This Project Demonstrates

- Infrastructure as Code using Terraform
- AWS VPC design with public, private and database subnet tiers
- Per-AZ NAT Gateway and route table design
- Amazon ECR repository with lifecycle policy
- Amazon EKS cluster provisioning
- Managed EKS node groups
- Kubernetes namespace, deployment, service and ingress manifests
- AWS Load Balancer Controller installed with Helm
- IAM Roles for Service Accounts using the EKS OIDC provider
- Secure Kubernetes runtime settings
- Real troubleshooting of EKS, Kubernetes and container runtime issues
- Five-tag FinOps tagging strategy applied through Terraform `default_tags`
- AWS Cost Explorer analysis by service and usage type
- Verified teardown and orphan-resource checks
- Evidence-led documentation for recruiter and interview review

## Technology Stack

- Terraform
- AWS VPC
- Amazon ECR
- Amazon EKS
- Kubernetes
- Helm
- AWS Load Balancer Controller
- IAM and IRSA
- Docker
- PowerShell
- AWS CLI
- kubectl
- AWS Cost Explorer

## Repository Structure

```text
app/                  Sample containerised application
docs/                 Project evidence, analysis and operating-model documentation
k8s/                  Kubernetes namespace, deployment, service and ingress manifests
terraform/bootstrap/  Terraform backend foundation
terraform/modules/    Reusable Terraform modules
terraform/envs/dev/   Development environment configuration
```

## Completed Platform Milestones

### Week 1 - Terraform Bootstrap

Created the foundation for a production-style Terraform workflow using remote state and locking.

### Week 2 - AWS Networking

Built a reusable VPC module with public, private and database subnet tiers and a two-AZ NAT pattern.

### Week 3 - Container Registry

Created and managed an Amazon ECR repository for the application image, including lifecycle controls.

### Week 4 - EKS Foundation

Provisioned an Amazon EKS cluster and managed node group using Terraform.

### Week 5 - EKS Application Behind ALB

Deployed the application into Kubernetes and exposed it publicly through an AWS Application Load Balancer.

Validation included:

```powershell
kubectl get nodes
kubectl get pods -n platform-dev
kubectl get deployment aws-platform-app -n platform-dev
kubectl get ingress -n platform-dev
curl.exe http://ALB_DNS_NAME/health
curl.exe http://ALB_DNS_NAME/
```

The health endpoint returned:

```json
{"status":"ok"}
```

## Issues Resolved

The project contains a real troubleshooting trail rather than only successful final-state code. Examples include:

- a managed node group blocked by account-level Free Tier restrictions, diagnosed through the underlying Auto Scaling Group activity;
- AWS CLI authentication schema incompatibility with a newer `kubectl` client;
- pod-capacity pressure on `t3.micro` nodes, followed by a move to `t3.small`;
- `runAsNonRoot` failing with a named container user and being corrected with numeric UID/GID values;
- ECR images preventing Terraform destroy until tagged and untagged image digests were removed.

See `docs/lessons-learned.md` and the week-by-week evidence under `docs/`.

## Cost Control and Teardown - IMPLEMENTED

After validation, the live AWS resources were safely removed to avoid unnecessary spend.

Final checks confirmed:

- Terraform state was empty
- no EKS clusters remained
- no load balancers remained
- no active NAT Gateways remained
- no Elastic IPs remained
- no EC2 worker nodes remained
- Git working tree was clean

Evidence: `docs/week-5-cost-control-teardown.md`.

## FinOps Cost Analysis - MEASURED

The project contains two layers of measured billing evidence.

The first is historical AWS Cost Explorer analysis for 20-30 April 2026, where total unblended Usage cost was **$1.9304346123**.

The second is a controlled August 2026 experiment using CUR 2.0 and Athena.

Baseline #1 used EKS 1.33 and measured:

- EKS standard control plane: $0.976863
- EKS extended-support surcharge: $4.884313
- total EKS: $5.861176
- effective EKS rate: approximately $0.60/hour
- gross core infrastructure: $7.488387

Run #2 changed only the EKS version to 1.34 and measured:

- EKS control plane: $1.117474
- no extended-support Usage line
- effective EKS rate: approximately $0.10/hour
- gross core infrastructure: $3.032617

Because Run #2 ran longer, the whole-stack comparison is normalised by environment runtime rather than comparing raw totals.

Normalised gross core infrastructure cost changed from approximately **$0.7666/hour to $0.2714/hour**, an observed reduction of approximately **64.6%**.

The isolated EKS control-plane reduction was **83.33%**.

AWS credits are reported separately from gross economic cost so promotional credits do not obscure the underlying architecture cost.

Evidence:

- `docs/evidence/baseline-run-2026-08-10_to_2026-08-11.txt`
- `docs/evidence/eks-upgrade-run2-2026-08-12.md`
- `docs/evidence/run2-timestamps-2026-08-12.txt`
- `docs/cost-analysis.md`

## FinOps Implementation Roadmap

The next controlled FinOps stages are:

1. run a third controlled experiment changing the dev architecture from two NAT Gateways to one while keeping EKS 1.34 and worker configuration unchanged;
2. compare NAT fixed cost and resilience trade-offs using CUR 2.0;
3. produce a tag-aware showback view from Athena;
4. codify the operational CUR 2.0 / Athena billing pipeline in infrastructure as code;
5. build an explicitly labelled 730-hour model from reconciled measured rates;
6. evaluate later compute opportunities such as Spot workers or rightsizing only if worker compute becomes material.

## CV-Ready Summary

Built and operated a production-style AWS platform using Terraform, EKS, ECR, Kubernetes, Helm, ALB and IRSA; implemented cost-allocation tagging, AWS Budgets and Cost Anomaly Detection; analysed CUR 2.0 billing data with Athena; identified an EKS extended-support cost exposure; and ran a controlled infrastructure experiment that reduced measured EKS control-plane cost by **83.33%**, while maintaining the rest of the test architecture for a like-for-like comparison.
