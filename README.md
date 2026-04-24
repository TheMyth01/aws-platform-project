# AWS Platform Project

Production-style AWS platform project showing Terraform, AWS networking, Docker, ECR, Amazon EKS, Kubernetes, ALB Ingress, IAM Roles for Service Accounts and FinOps-style cost control.

## Recruiter Summary

This project demonstrates practical cloud engineering experience across Terraform, AWS, Kubernetes, EKS, ECR, ALB Ingress, IAM, Helm and FinOps cost-control processes.

It shows the full lifecycle of a cloud platform build: provisioning infrastructure, deploying a containerised application, exposing it publicly through an AWS Application Load Balancer, troubleshooting real deployment issues, validating the live endpoint and safely tearing everything down to avoid unnecessary spend.

## Current Status

Week 5 complete.

A containerised application was deployed to Amazon EKS, exposed publicly through an AWS Application Load Balancer, validated with curl, documented, and then safely torn down.

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

Terraform manages the AWS infrastructure, including the VPC, subnets, route tables, NAT Gateways, EKS cluster, node group, ECR repository, IAM roles and IRSA setup.

## What This Project Demonstrates

- Infrastructure as Code using Terraform
- AWS VPC design with public, private and database subnet tiers
- NAT Gateway and route table configuration
- Amazon ECR repository for container images
- Amazon EKS cluster provisioning
- Managed EKS node groups
- Kubernetes namespace, deployment, service and ingress manifests
- AWS Load Balancer Controller installation with Helm
- IAM Roles for Service Accounts using the EKS OIDC provider
- Secure Kubernetes runtime settings
- Real troubleshooting of Kubernetes scheduling and container runtime errors
- FinOps-style tagging and teardown discipline
- Evidence-led documentation for portfolio and recruiter review

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
- FinOps tagging

## Repository Structure

```text
app/                  Sample containerised application
docs/                 Project evidence, milestone notes and teardown records
k8s/                  Kubernetes namespace, deployment, service and ingress manifests
terraform/bootstrap/  Terraform backend foundation
terraform/modules/    Reusable Terraform modules
terraform/envs/dev/   Development environment configuration
```

## Completed Milestones

### Week 1 - Terraform Bootstrap

Created the foundation for a production-style Terraform workflow.

### Week 2 - AWS Networking

Built a reusable VPC module with public, private and database subnet tiers.

### Week 3 - Container Registry

Created and managed an Amazon ECR repository for the application image.

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

The application endpoint returned:

```json
{
  "environment": "dev",
  "hostname": "pod-name",
  "message": "Hello from the AWS Platform Project"
}
```

## Issues Resolved

The first EKS node group used t3.micro instances, but the application pods could not schedule because the nodes hit pod capacity limits. The node group was updated to t3.small, Terraform replaced the node group, and the pods then scheduled successfully.

During deployment, the first version of the application pods also failed because the container image used a named non-root user while the Kubernetes deployment required runAsNonRoot: true.

This was fixed by adding a numeric runtime user:

```yaml
runAsUser: 1000
runAsGroup: 1000
```

## Cost Control and Teardown

After validation, the live AWS resources were safely removed to avoid unnecessary spend.

Final checks confirmed:

- Terraform state was empty
- No EKS clusters remained
- No load balancers remained
- No active NAT Gateways remained
- No Elastic IPs remained
- No EC2 worker nodes remained
- Git working tree was clean

This is documented in:

- docs/week-5-eks-alb.md
- docs/week-5-cost-control-teardown.md

## FinOps Approach

The project uses consistent tagging to support cost allocation and accountability:

- Project
- Environment
- Owner
- CostCenter
- ManagedBy

This project is designed to show not only how infrastructure is built, but also how it is validated, documented and shut down responsibly.

## CV-Ready Summary

Built and documented a production-style AWS platform using Terraform, EKS, ECR, Kubernetes, Helm and ALB Ingress, including IRSA-based controller permissions, secure runtime settings, live endpoint validation and FinOps-focused teardown controls.
