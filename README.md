# AWS Platform Project

Production-style AWS platform with FinOps layer.

## Status
Week 1 — Bootstrap

## Stack
- Terraform (IaC)
- AWS: VPC, EKS, RDS, ALB, CloudWatch, ECR, S3
- Docker + Kubernetes
- GitHub Actions (CI/CD)

## Structure
- `terraform/bootstrap/` — S3 state backend + DynamoDB lock
- `terraform/modules/` — reusable infra modules
- `terraform/envs/` — dev, staging environments
- `app/` — sample application
- `k8s/` — Kubernetes manifests
- `docs/` — architecture, runbooks, decisions

## FinOps
Tagging strategy: see `docs/tagging-strategy.md`.
All resources tagged with Project, Environment, Owner, CostCenter, ManagedBy.

---

## Current Milestone: EKS Application Behind AWS ALB

This project now includes a working containerised application deployed to Amazon EKS and exposed publicly through an AWS Application Load Balancer.

### What has been built

- Terraform-managed AWS VPC with public, private and database subnets
- NAT gateways and route tables for private subnet egress
- Amazon ECR repository for the application image
- Amazon EKS cluster running Kubernetes 1.33
- Managed node group using t3.small worker nodes
- AWS Load Balancer Controller installed using Helm
- IAM Roles for Service Accounts for the ALB Controller
- Kubernetes namespace, deployment, service and ingress manifests
- Public ALB endpoint successfully routing traffic to the application

### Validation evidence

The application was successfully tested through the public ALB endpoint:

```powershell
curl.exe http://<alb-dns-name>/health
```

Returned:

```json
{"status":"ok"}
```

```powershell
curl.exe http://<alb-dns-name>/
```

Returned:

```json
{
  "environment": "dev",
  "hostname": "<pod-name>",
  "message": "Hello from the AWS Platform Project"
}
```

### Issue resolved during deployment

During deployment, the pods initially failed because the container image used a named non-root user while the Kubernetes security context required `runAsNonRoot: true`.

This was fixed by adding a numeric runtime user:

```yaml
runAsUser: 1000
runAsGroup: 1000
```

After applying the fix and restarting the deployment, both pods became healthy and the ALB successfully routed traffic to the application.

### Why this matters

This milestone proves the project is more than static infrastructure code. It demonstrates a working AWS platform deployment with real operational validation, including Terraform, EKS, ECR, Kubernetes manifests, Helm, IRSA, ALB ingress, secure container runtime settings and hands-on troubleshooting.

