# ------------------------------------------------------------------
# Existing CUR 2.0 / Athena billing pipeline
# ------------------------------------------------------------------
#
# These resources adopt the already-operational billing pipeline into
# Terraform. They are intended to be imported before the first plan so
# Terraform does not create a duplicate export or replacement bucket.
#
# The Glue table itself is deliberately not managed here. The existing
# finops_cur_2 table is Athena-compatible metadata over the delivered
# Parquet files and can evolve with the CUR schema independently of this
# infrastructure definition.
#
# The live export uses output_type = ATHENA. The native hashicorp/aws
# aws_bcmdataexports_export resource currently validates CUSTOM only, so
# this export is managed through the official hashicorp/awscc provider,
# which is generated from the AWS CloudFormation / Cloud Control schema.

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  cur2_export_name        = "finops-cur-2"
  cur2_bucket_name        = "aws-platform-finops-cur2-inaam-2026"
  cur2_prefix             = "cur2"
  cur2_bucket_region      = "eu-west-2"
  cur2_glue_database_name = "finops-cur-2"

  cur2_query_statement = "SELECT bill_bill_type, bill_billing_entity, bill_billing_period_end_date, bill_billing_period_start_date, bill_invoice_id, bill_invoicing_entity, bill_payer_account_id, bill_payer_account_name, cost_category, discount, discount_bundled_discount, discount_total_discount, identity_line_item_id, identity_time_interval, line_item_availability_zone, line_item_blended_cost, line_item_blended_rate, line_item_currency_code, line_item_legal_entity, line_item_line_item_description, line_item_line_item_type, line_item_net_unblended_cost, line_item_net_unblended_rate, line_item_normalization_factor, line_item_normalized_usage_amount, line_item_operation, line_item_product_code, line_item_resource_id, line_item_tax_type, line_item_unblended_cost, line_item_unblended_rate, line_item_usage_account_id, line_item_usage_account_name, line_item_usage_amount, line_item_usage_end_date, line_item_usage_start_date, line_item_usage_type, line_item_user_identifier, pricing_currency, pricing_lease_contract_length, pricing_offering_class, pricing_public_on_demand_cost, pricing_public_on_demand_rate, pricing_purchase_option, pricing_rate_code, pricing_rate_id, pricing_term, pricing_unit, product, product_comment, product_fee_code, product_fee_description, product_from_location, product_from_location_type, product_from_region_code, product_instance_family, product_instance_type, product_instancesku, product_location, product_location_type, product_operation, product_pricing_unit, product_product_family, product_region_code, product_servicecode, product_sku, product_to_location, product_to_location_type, product_to_region_code, product_usagetype, reservation_amortized_upfront_cost_for_usage, reservation_amortized_upfront_fee_for_billing_period, reservation_availability_zone, reservation_effective_cost, reservation_end_time, reservation_modification_status, reservation_net_amortized_upfront_cost_for_usage, reservation_net_amortized_upfront_fee_for_billing_period, reservation_net_effective_cost, reservation_net_recurring_fee_for_usage, reservation_net_unused_amortized_upfront_fee_for_billing_period, reservation_net_unused_recurring_fee, reservation_net_upfront_value, reservation_normalized_units_per_reservation, reservation_number_of_reservations, reservation_recurring_fee_for_usage, reservation_reservation_a_r_n, reservation_start_time, reservation_subscription_id, reservation_total_reserved_normalized_units, reservation_total_reserved_units, reservation_units_per_reservation, reservation_unused_amortized_upfront_fee_for_billing_period, reservation_unused_normalized_unit_quantity, reservation_unused_quantity, reservation_unused_recurring_fee, reservation_upfront_value, resource_tags, savings_plan_amortized_upfront_commitment_for_billing_period, savings_plan_end_time, savings_plan_instance_type_family, savings_plan_net_amortized_upfront_commitment_for_billing_period, savings_plan_net_recurring_commitment_for_billing_period, savings_plan_net_savings_plan_effective_cost, savings_plan_offering_type, savings_plan_payment_option, savings_plan_purchase_term, savings_plan_recurring_commitment_for_billing_period, savings_plan_region, savings_plan_savings_plan_a_r_n, savings_plan_savings_plan_effective_cost, savings_plan_savings_plan_rate, savings_plan_start_time, savings_plan_total_commitment_to_date, savings_plan_used_commitment, split_line_item_actual_usage, split_line_item_net_split_cost, split_line_item_net_unused_cost, split_line_item_parent_resource_id, split_line_item_public_on_demand_split_cost, split_line_item_public_on_demand_unused_cost, split_line_item_reserved_usage, split_line_item_split_cost, split_line_item_split_usage, split_line_item_split_usage_ratio, split_line_item_unused_cost, tags FROM COST_AND_USAGE_REPORT"
}

# The billing bucket already contains historical CUR 2.0 data. Protect it
# from accidental Terraform destruction while it is managed by this stack.
resource "aws_s3_bucket" "cur2" {
  bucket        = local.cur2_bucket_name
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "cur2" {
  bucket = aws_s3_bucket.cur2.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cur2" {
  bucket = aws_s3_bucket.cur2.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cur2" {
  bucket = aws_s3_bucket.cur2.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Preserve the policy already used by AWS Billing Reports and BCM Data
# Exports. Source-account and source-ARN conditions keep delivery scoped to
# this account without hard-coding the account ID in the repository.
data "aws_iam_policy_document" "cur2_data_exports" {
  statement {
    sid    = "EnableAWSDataExportsToWriteToS3AndCheckPolicy"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "billingreports.amazonaws.com",
        "bcm-data-exports.amazonaws.com",
      ]
    }

    actions = [
      "s3:PutObject",
      "s3:GetBucketPolicy",
    ]

    resources = [
      aws_s3_bucket.cur2.arn,
      "${aws_s3_bucket.cur2.arn}/*",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*",
        "arn:${data.aws_partition.current.partition}:bcm-data-exports:us-east-1:${data.aws_caller_identity.current.account_id}:export/*",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cur2_data_exports" {
  bucket = aws_s3_bucket.cur2.id
  policy = data.aws_iam_policy_document.cur2_data_exports.json
}

# BCM Data Exports is exposed through the us-east-1 Cloud Control endpoint
# while the report destination remains the existing eu-west-2 S3 bucket.
resource "awscc_bcmdataexports_export" "cur2" {
  export = {
    name = local.cur2_export_name

    data_query = {
      query_statement = local.cur2_query_statement

      table_configurations = {
        COST_AND_USAGE_REPORT = {
          BILLING_VIEW_ARN                      = "arn:${data.aws_partition.current.partition}:billing::${data.aws_caller_identity.current.account_id}:billingview/primary"
          INCLUDE_CAPACITY_RESERVATION_DATA     = "FALSE"
          INCLUDE_IAM_PRINCIPAL_DATA            = "FALSE"
          INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = "FALSE"
          INCLUDE_RESOURCES                     = "TRUE"
          INCLUDE_SPLIT_COST_ALLOCATION_DATA    = "TRUE"
          TIME_GRANULARITY                      = "HOURLY"
        }
      }
    }

    destination_configurations = {
      s3_destination = {
        s3_bucket       = aws_s3_bucket.cur2.id
        s3_bucket_owner = data.aws_caller_identity.current.account_id
        s3_prefix       = local.cur2_prefix
        s3_region       = local.cur2_bucket_region

        s3_output_configurations = {
          output_type = "ATHENA"
          format      = "PARQUET"
          compression = "PARQUET"
          overwrite   = "OVERWRITE_REPORT"
        }
      }
    }

    refresh_cadence = {
      frequency = "SYNCHRONOUS"
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [aws_s3_bucket_policy.cur2_data_exports]
}

# The database is stable infrastructure. The generated/external table is
# intentionally left outside Terraform because its schema is derived from
# the delivered CUR metadata and can evolve independently.
resource "aws_glue_catalog_database" "cur2" {
  name = local.cur2_glue_database_name

  lifecycle {
    prevent_destroy = true
  }
}
