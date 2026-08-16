# CUR 2.0 / Athena IaC adoption - 16 August 2026

## Status

**IMPLEMENTED / VALIDATED**

The existing operational CUR 2.0 / Athena billing pipeline was adopted into Terraform without recreating the live export, replacing the S3 bucket, or changing the Glue database.

## Existing pipeline discovered before adoption

The live pipeline already contained:

- a healthy BCM Data Export named `finops-cur-2`;
- hourly Cost and Usage Report data with resource IDs and split-cost allocation data enabled;
- Athena-compatible Parquet output delivered to the existing FinOps S3 bucket in `eu-west-2`;
- overwrite delivery for the current report;
- an existing Glue database named `finops-cur-2` and external table `finops_cur_2`;
- S3 AES256 default encryption;
- S3 Block Public Access enabled for all four controls;
- `BucketOwnerEnforced` object ownership;
- a non-public bucket policy allowing AWS Billing Reports and BCM Data Exports delivery.

The existing Glue table was deliberately left outside Terraform because it is derived metadata over the delivered CUR files and can evolve independently of the stable infrastructure definition.

## Terraform scope

The following existing resources were imported into the FinOps Terraform state:

- CUR 2.0 S3 bucket;
- S3 public access block;
- S3 ownership controls;
- S3 server-side encryption configuration;
- S3 billing/data-export delivery policy;
- Glue catalog database;
- BCM Data Export.

The pre-existing Terraform-managed project budget, Cost Anomaly Detection monitor and daily anomaly subscription remained in the same state.

## Provider decision

The live export uses `output_type = ATHENA`.

During validation, the native `hashicorp/aws` BCM Data Exports resource rejected `ATHENA` because that provider resource validates the output type as `CUSTOM` only. The live AWS configuration was not changed to fit the provider.

Instead, the export was managed with the official `hashicorp/awscc` Cloud Control provider, which can represent the existing Athena output configuration. The rest of the AWS resources remain on the standard `hashicorp/aws` provider.

This preserves the working billing pipeline and records the provider capability boundary explicitly.

## Drift found and corrected during adoption

The first post-import plan identified an older Terraform drift in the Cost Anomaly Detection monitor: the live monitor used the tag key `user:Project`, while the repository configuration used `Project`.

Because changing the monitor specification would force replacement, no apply was performed. The Terraform configuration was corrected to represent the live monitor instead.

## Validation result

After the provider and anomaly-monitor corrections:

```text
terraform validate
Success! The configuration is valid.
```

`terraform plan` was then run twice. Both runs returned:

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

No `terraform apply` was required.

## Outcome

The operational billing pipeline is now represented in Infrastructure as Code with zero planned changes against the live AWS configuration.

The adoption demonstrates an evidence-led brownfield IaC workflow:

**discover -> model -> validate -> import -> inspect drift -> reconcile configuration -> prove zero-change plan**

The historical billing data and working export were preserved throughout.
