-- CUR 2.0 tag-aware showback for the controlled August 2026 experiment window.
-- Catalog: AwsDataCatalog
-- Database: finops-cur-2
-- Table: finops_cur_2
--
-- Scope is intentionally limited to line_item_line_item_type = 'Usage' so
-- credits and other billing adjustments remain separate from gross economic
-- cost. The five activated cost-allocation tags appear in CUR as user_* keys.

-- 1. Cost-weighted allocation coverage.
WITH base AS (
    SELECT
        line_item_unblended_cost AS gross_cost,
        element_at(resource_tags, 'user_project') AS project,
        element_at(resource_tags, 'user_environment') AS environment,
        element_at(resource_tags, 'user_owner') AS owner,
        element_at(resource_tags, 'user_cost_center') AS cost_center,
        element_at(resource_tags, 'user_managed_by') AS managed_by
    FROM finops_cur_2
    WHERE line_item_usage_start_date >= TIMESTAMP '2026-08-10 00:00:00'
      AND line_item_usage_start_date <  TIMESTAMP '2026-08-15 00:00:00'
      AND line_item_line_item_type = 'Usage'
),
classified AS (
    SELECT
        gross_cost,
        CASE
            WHEN NULLIF(project, '') IS NOT NULL
             AND NULLIF(environment, '') IS NOT NULL
             AND NULLIF(owner, '') IS NOT NULL
             AND NULLIF(cost_center, '') IS NOT NULL
             AND NULLIF(managed_by, '') IS NOT NULL
            THEN 'ALLOCATED'
            ELSE 'UNALLOCATED'
        END AS allocation_status
    FROM base
)
SELECT
    allocation_status,
    COUNT(*) AS cur_rows,
    ROUND(SUM(gross_cost), 6) AS gross_cost_usd,
    ROUND(
        100.0 * SUM(gross_cost) / SUM(SUM(gross_cost)) OVER (),
        2
    ) AS gross_cost_percent
FROM classified
GROUP BY allocation_status
ORDER BY gross_cost_usd DESC;

-- 2. Business-facing showback by ownership dimensions and AWS service.
SELECT
    COALESCE(NULLIF(element_at(resource_tags, 'user_project'), ''), 'UNALLOCATED') AS project,
    COALESCE(NULLIF(element_at(resource_tags, 'user_environment'), ''), 'UNALLOCATED') AS environment,
    COALESCE(NULLIF(element_at(resource_tags, 'user_cost_center'), ''), 'UNALLOCATED') AS cost_center,
    COALESCE(NULLIF(element_at(resource_tags, 'user_owner'), ''), 'UNALLOCATED') AS owner,
    COALESCE(NULLIF(element_at(resource_tags, 'user_managed_by'), ''), 'UNALLOCATED') AS managed_by,
    line_item_product_code AS service,
    ROUND(SUM(line_item_unblended_cost), 6) AS gross_cost_usd
FROM finops_cur_2
WHERE line_item_usage_start_date >= TIMESTAMP '2026-08-10 00:00:00'
  AND line_item_usage_start_date <  TIMESTAMP '2026-08-15 00:00:00'
  AND line_item_line_item_type = 'Usage'
GROUP BY 1, 2, 3, 4, 5, 6
HAVING ABS(SUM(line_item_unblended_cost)) > 0
ORDER BY gross_cost_usd DESC;

-- 3. Reconcile showback back to raw CUR Usage cost.
WITH raw_cur AS (
    SELECT
        SUM(line_item_unblended_cost) AS gross_cost
    FROM finops_cur_2
    WHERE line_item_usage_start_date >= TIMESTAMP '2026-08-10 00:00:00'
      AND line_item_usage_start_date <  TIMESTAMP '2026-08-15 00:00:00'
      AND line_item_line_item_type = 'Usage'
),
showback AS (
    SELECT
        SUM(gross_cost) AS gross_cost
    FROM (
        SELECT
            COALESCE(NULLIF(element_at(resource_tags, 'user_project'), ''), 'UNALLOCATED') AS project,
            COALESCE(NULLIF(element_at(resource_tags, 'user_environment'), ''), 'UNALLOCATED') AS environment,
            COALESCE(NULLIF(element_at(resource_tags, 'user_cost_center'), ''), 'UNALLOCATED') AS cost_center,
            COALESCE(NULLIF(element_at(resource_tags, 'user_owner'), ''), 'UNALLOCATED') AS owner,
            COALESCE(NULLIF(element_at(resource_tags, 'user_managed_by'), ''), 'UNALLOCATED') AS managed_by,
            line_item_product_code,
            SUM(line_item_unblended_cost) AS gross_cost
        FROM finops_cur_2
        WHERE line_item_usage_start_date >= TIMESTAMP '2026-08-10 00:00:00'
          AND line_item_usage_start_date <  TIMESTAMP '2026-08-15 00:00:00'
          AND line_item_line_item_type = 'Usage'
        GROUP BY 1, 2, 3, 4, 5, 6
    )
)
SELECT
    ROUND(raw_cur.gross_cost, 6) AS raw_cur_gross_cost,
    ROUND(showback.gross_cost, 6) AS showback_gross_cost,
    ROUND(showback.gross_cost - raw_cur.gross_cost, 10) AS reconciliation_difference
FROM raw_cur
CROSS JOIN showback;

-- 4. Drill into unallocated spend by service and usage type.
-- Use this to identify whether missing allocation is caused by untaggable
-- service charges, missing resource tags or a required shared-cost rule.
SELECT
    line_item_product_code AS service,
    line_item_usage_type,
    COUNT(*) AS cur_rows,
    ROUND(SUM(line_item_unblended_cost), 6) AS gross_cost_usd
FROM finops_cur_2
WHERE line_item_usage_start_date >= TIMESTAMP '2026-08-10 00:00:00'
  AND line_item_usage_start_date <  TIMESTAMP '2026-08-15 00:00:00'
  AND line_item_line_item_type = 'Usage'
  AND (
      NULLIF(element_at(resource_tags, 'user_project'), '') IS NULL
   OR NULLIF(element_at(resource_tags, 'user_environment'), '') IS NULL
   OR NULLIF(element_at(resource_tags, 'user_owner'), '') IS NULL
   OR NULLIF(element_at(resource_tags, 'user_cost_center'), '') IS NULL
   OR NULLIF(element_at(resource_tags, 'user_managed_by'), '') IS NULL
  )
GROUP BY 1, 2
HAVING ABS(SUM(line_item_unblended_cost)) > 0
ORDER BY gross_cost_usd DESC;
