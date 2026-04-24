# Week 5 – EKS Application Deployment Behind ALB

## Milestone

The AWS Platform Project now has a working Kubernetes application deployed to Amazon EKS and exposed publicly through an AWS Application Load Balancer.

## What was built

- Provisioned an EKS cluster using Terraform
- Created a managed node group running t3.small instances
- Created an ECR repository for the application image
- Installed the AWS Load Balancer Controller using Helm
- Created an IRSA role for the controller using Terraform
- Deployed the application into a dedicated Kubernetes namespace
- Exposed the application using a Kubernetes Service and ALB Ingress
- Verified the public ALB endpoint using curl

## Validation Evidence

```powershell
kubectl get nodes
```

Both EKS worker nodes were Ready.

```powershell
kubectl get pods -n platform-dev
```

The application was running with 2/2 pods Ready.

```powershell
kubectl get deployment aws-platform-app -n platform-dev
```

The deployment showed 2/2 available replicas.

```powershell
kubectl get ingress -n platform-dev
```

The ALB Ingress was created successfully and returned a public AWS load balancer address.

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

## Issue Resolved

The first deployment failed because the container image used a named non-root user, but the Kubernetes deployment had `runAsNonRoot: true` without a numeric user ID.

This was fixed by setting:

```yaml
runAsUser: 1000
runAsGroup: 1000
```

After applying the fix and restarting the deployment, the pods became healthy and the ALB successfully routed traffic to the application.

## Why this matters

This proves the project is not just infrastructure code. It is a working cloud platform deployment showing:

- Infrastructure as Code
- Kubernetes deployment
- Container image hosting with ECR
- Load-balanced public access
- IAM Roles for Service Accounts
- Secure container runtime settings
- Real troubleshooting and operational validation
