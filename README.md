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
- **Phase 2 - FinOps implementation: IN PROGRESS.**

The first measured cost analysis is now captured from AWS Cost Explorer for 20-30 April 2026. Total unblended Usage cost for that period was **$1.9304346123**. The environment was short-lived and included failed/partial build periods, so this number is evidence of actual usage, not a monthly baseline.

FinOps controls already implemented include Terraform tagging, an ECR lifecycle policy and verified teardown discipline. Cost allocation tag activation, Data Exports/CUR 2.0, Athena queries, budgets, anomaly detection and showback are the next implementation stages and are not claimed as complete.

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

AWS Cost Explorer was analysed using:

- date range: 20-30 April 2026
- metric: Unblended cost
- charge type: Usage
- daily granularity
- grouping by Service and then Usage Type

Measured total usage cost: **$1.9304346123**.

The two dominant measured cost drivers were the EKS control plane and NAT-related charges. EC2 worker compute was a much smaller share of the observed spend. Full figures and limitations are documented in `docs/cost-analysis.md`, with raw exported CSV evidence in `docs/evidence/`.

## FinOps Implementation Roadmap - DESIGNED

The next hands-on stages are:

1. activate the five cost allocation tags and capture evidence;
2. request historical tag backfill where available;
3. fix managed-node-group tag propagation to underlying instances/volumes/ENIs;
4. implement AWS Data Exports (CUR 2.0) to S3 in Terraform;
5. query exported cost data with Athena and SQL;
6. implement AWS Budgets and Cost Anomaly Detection;
7. run a measured, instrumented baseline deployment;
8. reconcile rate x quantity to actual cost;
9. produce a tagged showback report and decision log;
10. run a controlled optimisation comparison, such as two NAT Gateways versus one for dev.

## CV-Ready Summary

Built and operated a production-style AWS platform using Terraform, EKS, ECR, Kubernetes, Helm, ALB and IRSA; analysed real AWS Cost Explorer data at service and usage-type level, identified EKS and NAT as the dominant measured cost drivers, applied a five-tag provisioning strategy, and used verified teardown controls to prevent unnecessary non-production spend.
