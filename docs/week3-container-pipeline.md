# Week 3 — Container Pipeline Cost Analysis

**Environment:** dev
**Date:** 2026-04-22
**Decision:** ECR private repository with lifecycle policy, keep running between sessions

## What's running

| Resource | Monthly cost | Notes |
|---|---|---|
| ECR storage (~50 MB) | ~£0.004 | $0.10/GB/month, image is ~50 MB |
| ECR data transfer (push) | £0 | Uploads from laptop are free |
| ECR data transfer (pull) | £0 | Pulls within same AWS region are free |
| Vulnerability scanning | £0 | Basic scanning is free |

**Total: effectively £0/month.** Leave running — no destroy needed between sessions.

## Why ECR over alternatives

| Option | Storage cost | Pull cost to EKS | Notes |
|---|---|---|---|
| ECR private (this build) | $0.10/GB/mo | Free in-region | Native AWS, IAM auth, no egress fees |
| Docker Hub (free tier) | Free | Free | Rate-limited pulls, risk in production |
| Docker Hub (Pro $5/mo) | Free | Free | Ongoing subscription, external dependency |
| GitHub Container Registry | Free (public) / paid private | Egress fees to EKS | Extra egress cost not obvious upfront |

Choosing ECR keeps the whole stack inside AWS — no cross-provider egress, no rate limits, IAM-native authentication.

## Lifecycle policy implemented

Two rules defined in `terraform/modules/ecr/main.tf`:

1. **Keep last 10 tagged images** — older tagged images expire automatically
2. **Expire untagged images after 7 days** — prevents orphaned layers accumulating

**Why this matters at scale:** a CI/CD pipeline pushing an image per commit can accumulate hundreds of GB per repo per year without lifecycle rules. £0.004/month per image x 5000 images = meaningful waste. Building the discipline early.

## Dockerfile FinOps choices

- `python:3.12-slim` base (197 MB uncompressed) rather than full `python:3.12` (~1 GB) — 5x smaller storage + faster pulls
- Layer order: dependencies before source code, so code changes don't invalidate the pip install cache layer — faster builds, less CI/CD compute
- `--no-cache-dir` on pip — no cache files baked into the image

## Scan-on-push

Enabled in the ECR module (`scan_on_push = true`). Basic scanning is free. Catches known CVEs in the image on every push.

**Known issue on this image:** Docker 29 builds a multi-arch manifest by default, and ECR basic scanning doesn't always trigger on index-style manifests. Noted for Week 8 when we automate the build — will fix with `docker build --platform=linux/amd64` or ECR Enhanced Scanning (via AWS Inspector).

## Production recommendation

- Use `image_tag_mutability = IMMUTABLE` in production — prevents overwrites of a tag
- Move to ECR Enhanced Scanning for deeper CVE detection (paid, via Inspector)
- Tag images with git SHA, not just `latest` — reproducibility and rollback
- Pull-through cache for public images (avoid Docker Hub rate limits)
