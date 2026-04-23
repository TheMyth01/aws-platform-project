# Lessons Learned Log

## 2026-04-21 — Week 2: VPC Module + Dev Env

**What I built:** Reusable VPC module with 2 NAT Gateways, applied to dev env with S3 remote backend, verified in the console, then destroyed cleanly.

**What went well:**
- The remote backend worked properly and the dev environment picked up the S3 state without issues.
- Seeing the VPC, subnets, NAT Gateways and route tables in the AWS Console made the networking layout click properly.

**What surprised me / what I learned:**
- The route tables were the key part that made the HA NAT design make sense. Private route table 1 pointed to NAT 1 and private route table 2 pointed to NAT 2.
- I understood more clearly why 2 NAT Gateways cost more but remove the single point of failure across AZs.

**What I'd do differently next time:**
- I would read the Terraform plan even more slowly before applying so I can map every resource mentally before it is built.
- I want to test the single_nat_gateway option later in a separate environment so I can compare cost and resilience properly.

**Confidence level on topic:** Medium to high


## 2026-04-22 — Week 3: ECR, Docker, First Image Pushed

**What I built:** Reusable ECR module with lifecycle policy, Flask sample app containerised with a production-minded Dockerfile, image built and tested locally, pushed to ECR.

**What went well:**
- Building the Docker image and testing it locally went smoothly once the app files and Dockerfile were in place.
- Seeing the image successfully pushed to my own ECR repository made the full container workflow click properly.

**What surprised me / what I learned:**
- PowerShell piping caused an issue with the ECR login command, so I learned that splitting it into two commands was more reliable on Windows.
- I learned that using the `-target` flag can be useful in a controlled situation like creating only the ECR module, but it is not something to rely on for normal day-to-day Terraform workflows.

**What I'd do differently next time:**
- I would build the image in a way that avoids the manifest/scan issue so scan-on-push works exactly as expected in ECR.

**Confidence level on topic:** Medium


## 2026-04-23 — Week 4 (Attempt 1): EKS CREATE_FAILED — Free Tier blocked t3.medium

**What I built:** EKS module (cluster, 2 IAM roles, OIDC provider, managed node group) plus added kubernetes.io/role tags to VPC subnets for ALB. Terraform applied VPC and EKS control plane successfully. Node group got stuck in CREATE_FAILED for 30+ minutes.

**Root cause I diagnosed:**
- EKS `describe-nodegroup` showed status CREATING with no health issues — misleading, looked fine.
- Checked the Auto Scaling Group directly with `aws autoscaling describe-scaling-activities` and saw 5 failed launch attempts.
- Reason: "The specified instance type is not eligible for Free Tier." My AWS account has Free Tier enforcement enabled which blocks non-Free-Tier instance types like t3.medium.

**What I learned:**
- EKS health APIs can return empty even when the ASG underneath is failing. The ASG scaling activities log is the more reliable diagnostic.
- Free Tier enforcement is an account-level guardrail — not obvious from the error until you dig into ASG activities.
- Partial-apply cleanup is painful. When destroy fails, you end up with orphan resources and confused Terraform state. Had to delete a CREATE_FAILED node group directly via CLI, then target-destroy each module separately.

**Fix for next session:** change node_instance_types from ["t3.medium"] to ["t3.micro"] in dev main.tf. t3.micro is Free Tier eligible.

**What I would do differently:**
- Check account-level Free Tier / Service Control Policy restrictions before designing node sizing.
- For a personal AWS account with Free Tier enforcement, default to Free Tier instance types unless I explicitly disable the guardrail.

**Confidence level on topic:** Low (cluster never reached working state — deferred to next session).
