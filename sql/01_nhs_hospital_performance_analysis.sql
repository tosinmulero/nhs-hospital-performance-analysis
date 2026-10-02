-- ============================================================
-- NHS Hospital Performance & Patient Flow Analysis
-- PostgreSQL Analysis
-- Period: April 2026 to August 2026
-- ============================================================


-- ============================================================
-- 1. DATA QUALITY CHECKS
-- ============================================================

-- Total imported rows
SELECT COUNT(*) AS total_rows
FROM ae_provider_performance;


-- Rows by reporting month
SELECT
    reporting_month,
    COUNT(*) AS provider_rows
FROM ae_provider_performance
GROUP BY reporting_month
ORDER BY reporting_month;


-- Missing key identifiers
SELECT
    COUNT(*) FILTER (
        WHERE provider_code IS NULL
    ) AS missing_provider_codes,

    COUNT(*) FILTER (
        WHERE provider_name IS NULL
    ) AS missing_provider_names,

    COUNT(*) FILTER (
        WHERE region IS NULL
    ) AS missing_regions,

    COUNT(*) FILTER (
        WHERE reporting_month IS NULL
    ) AS missing_reporting_months

FROM ae_provider_performance;


-- Duplicate provider-month records
SELECT
    provider_code,
    reporting_month,
    COUNT(*) AS duplicate_count
FROM ae_provider_performance
GROUP BY
    provider_code,
    reporting_month
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 2. NATIONAL MONTHLY PERFORMANCE
-- ============================================================

SELECT
    reporting_month,

    SUM(total_attendances)::BIGINT
        AS total_attendances,

    SUM(total_under_4h)::BIGINT
        AS attendances_under_4h,

    SUM(total_over_4h)::BIGINT
        AS attendances_over_4h,

    ROUND(
        100.0 * SUM(total_under_4h)
        / NULLIF(SUM(total_attendances), 0),
        2
    ) AS four_hour_performance_pct,

    ROUND(
        100.0 * SUM(total_over_4h)
        / NULLIF(SUM(total_attendances), 0),
        2
    ) AS over_4h_pct,

    SUM(total_emergency_admissions_via_ae)::BIGINT
        AS emergency_admissions_via_ae,

    SUM(decision_to_admit_over_4h)::BIGINT
        AS decision_to_admit_over_4h,

    SUM(decision_to_admit_over_12h)::BIGINT
        AS decision_to_admit_over_12h

FROM ae_provider_performance

GROUP BY reporting_month

ORDER BY reporting_month;


-- ============================================================
-- 3. REGIONAL FOUR-HOUR PERFORMANCE
-- ============================================================

SELECT
    region,

    SUM(total_attendances)::BIGINT
        AS total_attendances,

    SUM(total_under_4h)::BIGINT
        AS attendances_under_4h,

    SUM(total_over_4h)::BIGINT
        AS attendances_over_4h,

    ROUND(
        100.0 * SUM(total_under_4h)
        / NULLIF(SUM(total_attendances), 0),
        2
    ) AS four_hour_performance_pct,

    ROUND(
        100.0 * SUM(total_over_4h)
        / NULLIF(SUM(total_attendances), 0),
        2
    ) AS over_4h_pct

FROM ae_provider_performance

GROUP BY region

ORDER BY four_hour_performance_pct DESC;


-- ============================================================
-- 4. MONTHLY REGIONAL PERFORMANCE TREND
-- ============================================================

SELECT
    reporting_month,
    region,

    SUM(total_attendances)::BIGINT
        AS total_attendances,

    SUM(total_under_4h)::BIGINT
        AS attendances_under_4h,

    ROUND(
        100.0 * SUM(total_under_4h)
        / NULLIF(SUM(total_attendances), 0),
        2
    ) AS four_hour_performance_pct

FROM ae_provider_performance

GROUP BY
    reporting_month,
    region

ORDER BY
    reporting_month,
    region;


-- ============================================================
-- 5. REGIONAL PATIENT FLOW / 12-HOUR WAITS
-- ============================================================

SELECT
    region,

    SUM(total_emergency_admissions_via_ae)::BIGINT
        AS ae_emergency_admissions,

    SUM(decision_to_admit_over_4h)::BIGINT
        AS over_4h_decision_to_admit,

    SUM(decision_to_admit_over_12h)::BIGINT
        AS over_12h_decision_to_admit,

    ROUND(
        1000.0 * SUM(decision_to_admit_over_4h)
        / NULLIF(
            SUM(total_emergency_admissions_via_ae),
            0
        ),
        2
    ) AS over_4h_per_1000_admissions,

    ROUND(
        1000.0 * SUM(decision_to_admit_over_12h)
        / NULLIF(
            SUM(total_emergency_admissions_via_ae),
            0
        ),
        2
    ) AS over_12h_per_1000_admissions

FROM ae_provider_performance

GROUP BY region

ORDER BY over_12h_per_1000_admissions DESC;


-- ============================================================
-- 6. MONTHLY PATIENT FLOW
-- ============================================================

SELECT
    reporting_month,

    SUM(total_emergency_admissions_via_ae)::BIGINT
        AS ae_emergency_admissions,

    SUM(decision_to_admit_over_4h)::BIGINT
        AS over_4h_decision_to_admit,

    SUM(decision_to_admit_over_12h)::BIGINT
        AS over_12h_decision_to_admit,

    ROUND(
        1000.0 * SUM(decision_to_admit_over_4h)
        / NULLIF(
            SUM(total_emergency_admissions_via_ae),
            0
        ),
        2
    ) AS over_4h_per_1000_admissions,

    ROUND(
        1000.0 * SUM(decision_to_admit_over_12h)
        / NULLIF(
            SUM(total_emergency_admissions_via_ae),
            0
        ),
        2
    ) AS over_12h_per_1000_admissions

FROM ae_provider_performance

GROUP BY reporting_month

ORDER BY reporting_month;


-- ============================================================
-- 7. TYPE 1 PROVIDER BENCHMARK
-- COMPLETE FIVE-MONTH REPORTING ONLY
-- ============================================================

WITH latest_provider AS (

    SELECT DISTINCT ON (provider_code)
        provider_code,
        provider_name,
        region

    FROM ae_provider_performance

    ORDER BY
        provider_code,
        reporting_month DESC
),

provider_summary AS (

    SELECT
        provider_code,

        COUNT(
            DISTINCT reporting_month
        ) AS months_reported,

        SUM(type1_attendances)
            AS type1_attendances,

        SUM(type1_under_4h)
            AS type1_under_4h

    FROM ae_provider_performance

    GROUP BY provider_code
)

SELECT
    lp.provider_name,
    lp.region,

    ps.type1_attendances::BIGINT
        AS type1_attendances,

    ROUND(
        100.0 * ps.type1_under_4h
        / NULLIF(ps.type1_attendances, 0),
        2
    ) AS type1_four_hour_performance_pct

FROM provider_summary ps

JOIN latest_provider lp
    ON ps.provider_code = lp.provider_code

WHERE
    ps.months_reported = 5
    AND ps.type1_attendances > 0

ORDER BY
    type1_four_hour_performance_pct DESC;


-- ============================================================
-- 8. APRIL TO AUGUST TYPE 1 PROVIDER CHANGE
-- ============================================================

WITH latest_provider AS (

    SELECT DISTINCT ON (provider_code)
        provider_code,
        provider_name,
        region

    FROM ae_provider_performance

    ORDER BY
        provider_code,
        reporting_month DESC
),

monthly_performance AS (

    SELECT
        provider_code,
        reporting_month,

        SUM(type1_attendances)
            AS type1_attendances,

        SUM(type1_under_4h)
            AS type1_under_4h

    FROM ae_provider_performance

    WHERE
        reporting_month IN (
            DATE '2026-04-01',
            DATE '2026-08-01'
        )
        AND type1_attendances > 0

    GROUP BY
        provider_code,
        reporting_month
),

provider_change AS (

    SELECT
        provider_code,

        MAX(
            CASE
                WHEN reporting_month = DATE '2026-04-01'
                THEN
                    100.0 * type1_under_4h
                    / NULLIF(type1_attendances, 0)
            END
        ) AS apr_2026_pct,

        MAX(
            CASE
                WHEN reporting_month = DATE '2026-08-01'
                THEN
                    100.0 * type1_under_4h
                    / NULLIF(type1_attendances, 0)
            END
        ) AS aug_2026_pct

    FROM monthly_performance

    GROUP BY provider_code
)

SELECT
    lp.provider_name,
    lp.region,

    ROUND(
        pc.apr_2026_pct,
        2
    ) AS apr_2026_pct,

    ROUND(
        pc.aug_2026_pct,
        2
    ) AS aug_2026_pct,

    ROUND(
        pc.aug_2026_pct
        - pc.apr_2026_pct,
        2
    ) AS change_pp

FROM provider_change pc

JOIN latest_provider lp
    ON pc.provider_code = lp.provider_code

WHERE
    pc.apr_2026_pct IS NOT NULL
    AND pc.aug_2026_pct IS NOT NULL

ORDER BY change_pp DESC;


-- ============================================================
-- 9. POWER BI ANALYTICAL VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_ae_provider_performance AS

SELECT
    reporting_month,
    provider_code,
    provider_name,
    region,

    type1_attendances,
    type2_attendances,
    type3_attendances,
    total_attendances,

    type1_under_4h,
    type2_under_4h,
    type3_under_4h,
    total_under_4h,

    type1_over_4h,
    type2_over_4h,
    type3_over_4h,
    total_over_4h,

    ROUND(
        100.0 * total_under_4h
        / NULLIF(total_attendances, 0),
        2
    ) AS four_hour_performance_pct,

    ROUND(
        100.0 * total_over_4h
        / NULLIF(total_attendances, 0),
        2
    ) AS over_4h_pct,

    ROUND(
        100.0 * type1_under_4h
        / NULLIF(type1_attendances, 0),
        2
    ) AS type1_four_hour_performance_pct,

    total_emergency_admissions_via_ae,
    other_emergency_admissions,
    total_emergency_admissions,

    decision_to_admit_over_4h,
    decision_to_admit_over_12h,

    ROUND(
        1000.0 * decision_to_admit_over_4h
        / NULLIF(
            total_emergency_admissions_via_ae,
            0
        ),
        2
    ) AS dta_over_4h_per_1000,

    ROUND(
        1000.0 * decision_to_admit_over_12h
        / NULLIF(
            total_emergency_admissions_via_ae,
            0
        ),
        2
    ) AS dta_over_12h_per_1000

FROM ae_provider_performance;


-- ============================================================
-- 10. VERIFY POWER BI VIEW
-- ============================================================

SELECT
    COUNT(*) AS view_rows
FROM vw_ae_provider_performance;