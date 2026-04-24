# Week 5 – Cost Control and Teardown Evidence

## Milestone

After successfully deploying the application to Amazon EKS behind an AWS Application Load Balancer, the live AWS infrastructure was safely removed to avoid unnecessary cloud spend.

This shows the project was not only built and tested, but also operated responsibly with cost awareness.

## What was cleaned down

The following live AWS resources were removed after validation:

- Kubernetes Ingress for the public ALB
- Application namespace and running pods
- EKS managed node group
- EKS cluster
- NAT Gateways
- Elastic IPs
- VPC, subnets and route tables
- IAM roles and policies created for the EKS cluster
- ECR lifecycle policy
- ECR container images
- ECR repository

## Why the Ingress was deleted first

The Kubernetes Ingress was deleted before running Terraform destroy.

This allowed the AWS Load Balancer Controller to remove the AWS Application Load Balancer cleanly before the EKS cluster itself was destroyed.

```powershell
kubectl delete ingress aws-platform-ingress -n platform-dev
```

Validation:

```powershell
kubectl get ingress -n platform-dev
```

Result:

```powershell
No resources found in platform-dev namespace.
```

## Namespace cleanup

The application namespace was removed after the ALB resources had been cleared.

```powershell
kubectl delete namespace platform-dev
```

Validation:

```powershell
kubectl get namespace platform-dev
```

Result:

```powershell
Error from server (NotFound): namespaces "platform-dev" not found
```

## Terraform destroy

A destroy plan was reviewed before approving deletion.

```powershell
terraform plan -destroy
```

Result:

```powershell
Plan: 0 to add, 0 to change, 37 to destroy.
```

Terraform destroy was then approved.

```powershell
terraform destroy
```

The main infrastructure was destroyed, including the EKS cluster, node group, NAT Gateways and VPC resources.

## ECR cleanup issue resolved

Terraform could not initially delete the ECR repository because container images still existed inside it.

The tagged image was deleted first:

```powershell
aws ecr batch-delete-image --repository-name aws-platform-dev-app --region eu-west-2 --image-ids imageTag=latest
```

Two remaining untagged image digests were then found:

```powershell
aws ecr list-images --repository-name aws-platform-dev-app --region eu-west-2 --output table
```

They were deleted using:

```powershell
aws ecr batch-delete-image `
  --repository-name aws-platform-dev-app `
  --region eu-west-2 `
  --image-ids imageDigest=sha256:af12782c528d68e55284b4443408b8336e98816c6c086e7a540b1f725186b782 imageDigest=sha256:c92376ae2de46cbec07286b70431875a66a2e54237beceb75c4723a26f19e3b8
```

Terraform destroy was then run again and completed successfully.

```powershell
Destroy complete! Resources: 1 destroyed.
```

## Final validation checks

Terraform state was empty:

```powershell
terraform state list
```

No resources were returned.

EKS clusters were checked:

```powershell
aws eks list-clusters --region eu-west-2 --output table
```

Result:

```powershell
--------------
|ListClusters|
+------------+
```

Load balancers were checked:

```powershell
aws elbv2 describe-load-balancers --region eu-west-2 --output table
```

Result:

```powershell
-----------------------
|DescribeLoadBalancers|
+---------------------+
```

Active NAT Gateways were checked:

```powershell
aws ec2 describe-nat-gateways --region eu-west-2 --filter Name=state,Values=available,pending --output table
```

Result:

```powershell
---------------------
|DescribeNatGateways|
+-------------------+
```

Elastic IPs were checked:

```powershell
aws ec2 describe-addresses --region eu-west-2 --filters Name=tag:Project,Values=aws-platform --output table
```

Result:

```powershell
-------------------
|DescribeAddresses|
+-----------------+
```

EC2 worker nodes were checked:

```powershell
aws ec2 describe-instances --region eu-west-2 --filters Name=tag:Project,Values=aws-platform Name=instance-state-name,Values=pending,running,stopping,stopped --output table
```

Result:

```powershell
-------------------
|DescribeInstances|
+-----------------+
```

Git was also checked:

```powershell
git status
```

Result:

```powershell
nothing to commit, working tree clean
```

## Why this matters

This teardown proves the project was managed with real operational discipline.

It demonstrates:

- Cloud cost awareness
- Safe deletion order for Kubernetes and AWS resources
- Understanding of ALB controller behaviour
- Terraform destroy planning
- ECR image lifecycle troubleshooting
- AWS CLI validation
- Clean Git workflow
- FinOps-style accountability after deployment

This is important because cloud engineering is not only about building infrastructure. It is also about operating it safely, validating it properly and controlling unnecessary spend.
