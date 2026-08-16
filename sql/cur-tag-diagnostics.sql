-- CUR 2.0 tag diagnostics for the tag-aware showback stage.
-- Run against AwsDataCatalog / finops-cur-2 / finops_cur_2.
-- These queries intentionally inspect the schema before the final showback
-- query is committed so tag extraction is based on observed CUR structure.

-- 1. Confirm the Athena type used for resource_tags.
SELECT typeof(resource_tags) AS resource_tags_type
FROM finops_cur_2
LIMIT 1;

-- 2. Inspect representative non-null tag payloads without assuming whether
--    resource_tags is a map, row or another Athena-supported type.
SELECT
    line_item_usage_start_date,
    line_item_product_code,
    line_item_resource_id,
    resource_tags
FROM finops_cur_2
WHERE resource_tags IS NOT NULL
ORDER BY line_item_usage_start_date DESC
LIMIT 20;

-- 3. Inspect rows from the controlled August experiments so the final
--    showback query can be reconciled to known measured billing evidence.
SELECT
    line_item_usage_start_date,
    line_item_product_code,
    line_item_usage_type,
    line_item_resource_id,
    line_item_line_item_type,
    line_item_unblended_cost,
    resource_tags
FROM finops_cur_2
WHERE line_item_usage_start_date >= TIMESTAMP '2026-08-10 00:00:00'
  AND line_item_usage_start_date <  TIMESTAMP '2026-08-15 00:00:00'
  AND resource_tags IS NOT NULL
ORDER BY line_item_usage_start_date DESC
LIMIT 50;
