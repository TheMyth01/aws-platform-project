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
