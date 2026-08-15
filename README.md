# AWS Platform Project

Production-style AWS platform built end to end with Terraform and Amazon EKS, then operated as an evidence-led FinOps case study using measured AWS Cost Explorer and CUR 2.0 / Athena billing data.

## Recruiter Summary

This project demonstrates practical cloud engineering and FinOps experience across Terraform, AWS networking, EKS, ECR, Kubernetes, ALB Ingress, IAM/IRSA, Helm, troubleshooting, cost allocation, billing analysis, governance controls and measured optimisation.

The platform was provisioned, a containerised application was deployed to EKS and exposed through an AWS Application Load Balancer, the live endpoint was validated, real deployment failures were debugged, and the environment was then safely torn down to stop unnecessary non-production spend.

The FinOps work goes beyond generic recommendations: cost drivers were identified from measured AWS billing data, one infrastructure variable was changed at a time, the result was measured through CUR 2.0 / Athena, and engineering trade-offs were documented alongside the cost outcome.

## Status Legend

- **IMPLEMENTED**: built or configured and supported by code or captured evidence in this repository.
- **MEASURED**: derived from captured AWS billing data committed under `docs/evidence/`.
- **DESIGNED**: target-state control or optimisation that has not yet been implemented.
- **MODELLED**: analytical scenario, clearly separated from realised AWS spend.

## Current Status

- **Phase 1 - Platform build: COMPLETE.**
- **Phase 2 - FinOps implementation and controlled optimisation: IN PROGRESS, WITH TWO MEASURED OPTIMISATIONS.**

The project now includes historical Cost Explorer analysis and three controlled CUR 2.0 / Athena runs.

### Measured FinOps Results

| Experiment | Controlled change | Measured result |
|---|---|---:|
| Baseline #1 -> Run #2 | EKS 1.33 -> 1.34; workers, NAT count and VPC unchanged | **83.33% lower EKS control-plane cost** |
| Run #2 -> Run #3 | 2 NAT Gateways -> 1; EKS 1.34, workers and VPC/subnets retained | **50% lower fixed NAT + associated IPv4 rate** |

Baseline #1 measured an EKS control-plane rate of approximately **$0.60/hour**, including a **$0.50/hour extended-support surcharge**.

Run #2 changed only the EKS version to Kubernetes 1.34 while retaining two `t3.small` workers, two NAT Gateways and the same VPC architecture. CUR 2.0 showed no extended-support Usage line and measured an EKS control-plane rate of approximately **$0.10/hour**. This produced the measured **83.33% EKS control-plane cost reduction**.

Run #3 retained EKS 1.34 and the same worker/VPC configuration but reduced NAT Gateway count from two to one. Measured fixed networking rate changed from approximately **$0.11/hour to $0.055/hour**, a **50% reduction** in NAT Gateway plus associated public IPv4 fixed cost.

Normalised gross core infrastructure cost changed from approximately **$0.271381 to $0.209652 per environment-hour** between Run #2 and Run #3, an observed reduction of approximately **22.75%**. This whole-stack percentage is presented as an observed normalised result rather than the isolated causal saving because the runs had different durations and hourly billing boundaries.

Run #3 also records the engineering trade-off: a shared NAT removes independent AZ-local egress and can introduce cross-AZ traffic. That makes the decision appropriate for this dev cost target, but not a blanket recommendation for production.

Additional implemented FinOps controls include:

- activated project cost-allocation tags with historical backfill;
- launch-template tag propagation to EKS worker instances, volumes and network interfaces;
- CUR 2.0 billing analysis through Amazon Athena;
- a project-scoped AWS Budget managed through Terraform;
- a project-scoped Cost Anomaly Detection monitor and daily subscription managed through Terraform;
- verified teardown discipline and orphan-resource checks for non-production infrastructure.

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

Terraform manages the AWS infrastructure, including the VPC, subnets, route tables, NAT Gateway configuration, EKS cluster, managed node group, ECR repository, IAM roles and IRSA setup.

The dev environment now defaults to a measured single-NAT cost target. The VPC module still supports the multi-AZ NAT pattern so production resilience requirements can be evaluated separately from the dev optimisation.

## What This Project Demonstrates

- Infrastructure as Code using Terraform
- AWS VPC design with public, private and database subnet tiers
- Configurable multi-AZ versus single-NAT architecture
- Amazon ECR repository with lifecycle policy
- Amazon EKS cluster provisioning
- Managed EKS node groups
- Kubernetes namespace, deployment, service and ingress manifests
- AWS Load Balancer Controller installed with Helm
- IAM Roles for Service Accounts using the EKS OIDC provider
- Secure Kubernetes runtime settings
- Real troubleshooting of EKS, Kubernetes and container runtime issues
- Five-tag FinOps tagging strategy applied through Terraform `default_tags`
- EKS worker instance, EBS and ENI tag propagation
- AWS Cost Explorer analysis by service and usage type
- CUR 2.0 / Athena analysis at usage-type level
- AWS Budget and Cost Anomaly Detection controls managed through Terraform
- Controlled cost optimisation with measured before/after evidence
- Explicit separation of measured, implemented, designed and modelled claims
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
- AWS CUR 2.0
- Amazon Athena
- AWS Budgets
- AWS Cost Anomaly Detection

## Repository Structure

```text
app/                  Sample containerised application
docs/                 Project evidence, analysis and operating-model documentation
k8s/                  Kubernetes namespace, deployment, service and ingress manifests
terraform/bootstrap/  Terraform backend foundation
terraform/modules/    Reusable Terraform modules
terraform/envs/dev/   Development environment configuration
terraform/envs/finops/ FinOps governance controls
```

## Completed Platform Milestones

### Week 1 - Terraform Bootstrap

Created the foundation for a production-style Terraform workflow using remote state and locking.

### Week 2 - AWS Networking

Built a reusable VPC module with public, private and database subnet tiers plus configurable NAT architecture.

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

After validation and each controlled optimisation run, the live AWS resources were safely removed to avoid unnecessary spend.

Run #3 post-destroy checks confirmed:

- Terraform state was empty
- no EKS clusters remained
- no load balancers remained
- no active NAT Gateways remained
- no Elastic IPs remained
- no project EC2 worker nodes remained
- no project ECR repository remained

Evidence includes `docs/week-5-cost-control-teardown.md` and `docs/evidence/run3-timestamps-2026-08-13_to_2026-08-14.txt`.

## FinOps Cost Analysis - MEASURED

The project contains two layers of measured billing evidence.

The first is historical AWS Cost Explorer analysis for 20-30 April 2026, where total unblended Usage cost was **$1.9304346123**.

The second is a controlled August 2026 experiment series using CUR 2.0 and Athena.

### Baseline #1 - EKS 1.33, two NAT Gateways

Measured:

- EKS standard control plane: $0.976863
- EKS extended-support surcharge: $4.884313
- total EKS: $5.861176
- effective EKS rate: approximately $0.60/hour
- gross core infrastructure: $7.488387

### Run #2 - EKS 1.34, two NAT Gateways

Changed only the EKS version and measured:

- EKS control plane: $1.117474
- no extended-support Usage line
- effective EKS rate: approximately $0.10/hour
- gross core infrastructure: $3.032617
- measured EKS control-plane reduction: **83.33%**
- observed normalised whole-stack reduction versus baseline: **approximately 64.6%**

### Run #3 - EKS 1.34, one NAT Gateway

Retained the Run #2 EKS version, worker configuration and VPC/subnet structure while changing NAT Gateway count from two to one.

Measured:

- EKS: 27.076600 hours / $2.707660 gross
- `t3.small` workers: 53.974445 hours / $1.273797 gross
- NAT Gateway: 28 hours / $1.400000 gross
- NAT processing: 0.501710 GB / $0.025086 gross
- EBS gp3: $0.134710 gross
- public IPv4 in-use: $0.135183 gross
- core infrastructure: **$5.676672 gross**
- normalised core cost: **$0.209652 per environment-hour**

Compared with Run #2's **$0.271381 per environment-hour**, Run #3 produced an observed normalised whole-stack reduction of approximately **22.75%**.

The cleaner isolated networking result is the fixed-rate change:

- two NATs + two associated public IPv4 addresses: **$0.11/hour**
- one NAT + one associated public IPv4 address: **$0.055/hour**
- measured fixed networking rate reduction: **50%**

At 730 operating hours, the measured unit-rate difference implies a **MODELLED** fixed-cost reduction of approximately **$40.15/month**. This is explicitly not presented as realised monthly spend.

AWS credits are reported separately from gross economic cost so promotional credits do not obscure the underlying architecture cost.

Evidence:

- `docs/evidence/baseline-run-2026-08-10_to_2026-08-11.txt`
- `docs/evidence/eks-upgrade-run2-2026-08-12.md`
- `docs/evidence/run2-timestamps-2026-08-12.txt`
- `docs/evidence/run3-timestamps-2026-08-13_to_2026-08-14.txt`
- `docs/evidence/single-nat-run3-2026-08-13_to_2026-08-14.md`
- `docs/cost-analysis.md`

## FinOps Implementation Roadmap

The next FinOps stages are deliberately selected from measured evidence rather than generic cloud-cost advice:

1. produce a tag-aware Athena showback view using the activated project cost-allocation tags;
2. codify the operational CUR 2.0 / Athena billing pipeline in infrastructure as code;
3. extend the explicitly labelled 730-hour model using reconciled measured EKS and networking rates;
4. evaluate later compute opportunities such as Spot workers or rightsizing only if worker compute becomes materially significant.

## Interview Narrative

The project follows a repeatable FinOps decision loop:

**Build -> Measure -> Find -> Decide -> Change -> Validate -> Govern**

A concise interview example is:

> I built a production-style EKS platform in Terraform and instrumented the cost side with allocation tags, Cost Explorer, CUR 2.0 / Athena, Budgets and anomaly controls. CUR identified an EKS extended-support surcharge, so I ran a controlled 1.33-to-1.34 experiment that reduced the measured EKS control-plane rate from about $0.60/hour to $0.10/hour, an 83.33% reduction. I then isolated NAT architecture in a second controlled experiment: moving the dev environment from two NAT Gateways to one cut the fixed NAT plus associated IPv4 rate by 50%, while I explicitly documented the resilience and cross-AZ trade-off rather than treating cheaper as automatically better.

## CV-Ready Summary

Built and operated a production-style AWS platform using Terraform, EKS, ECR, Kubernetes, Helm, ALB and IRSA; implemented cost-allocation tagging, AWS Budgets and Cost Anomaly Detection; analysed CUR 2.0 billing data with Athena; identified and removed an EKS extended-support cost exposure through a controlled experiment that reduced measured EKS control-plane cost by **83.33%**; then ran a second controlled architecture experiment that reduced the fixed NAT Gateway plus associated public IPv4 rate by **50%**, with the resilience trade-off documented and supported by measured AWS billing evidence.
