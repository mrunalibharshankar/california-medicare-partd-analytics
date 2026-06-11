-- ============================================================
-- Top Prescribers by Spend — Outlier Detection
-- Identifies individual prescribers with highest drug spend
-- ============================================================

WITH
  prescriber_spend AS (

    -- Step 1: aggregate spend per prescriber
    SELECT
      prescriber_npi,
      prescriber_last_or_org_name AS last_name,
      prescriber_first_name AS first_name,
      prescriber_city AS city,
      prescriber_specialty AS specialty,
      COUNT(DISTINCT drug_generic_name) AS unique_drugs,
      SUM(total_claims) AS total_claims,
      ROUND(SUM(total_drug_cost), 2) AS total_spend,
      ROUND(
        SAFE_DIVIDE(SUM(total_drug_cost), SUM(total_claims)), 2)
        AS cost_per_claim
    FROM
      `cms-medicare-prescriber-data.cms_medicare.partd_clean`
    GROUP BY
      prescriber_npi,
      prescriber_last_or_org_name,
      prescriber_first_name,
      prescriber_city,
      prescriber_specialty
  ),
  specialty_avg AS (

    -- Step 2: calculate average cost per claim for each specialty
    -- This is the benchmark each prescriber is compared against
    SELECT
      specialty,
      ROUND(
        AVG(cost_per_claim), 2) AS specialty_avg_cost_per_claim
    FROM prescriber_spend
    GROUP BY specialty
  )

-- Step 3: join and flag outliers
SELECT
  p.prescriber_npi,
  p.last_name,
  p.first_name,
  p.city,
  p.specialty,
  p.unique_drugs,
  p.total_claims,
  p.total_spend,
  p.cost_per_claim,
  s.specialty_avg_cost_per_claim,

  -- How much MORE this prescriber costs vs. their specialty average
  ROUND(
    p.cost_per_claim - s.specialty_avg_cost_per_claim,
    2) AS variance_from_specialty_avg,

  -- % above or below specialty average — the outlier flag
  ROUND(
    100.0 * SAFE_DIVIDE(
      p.cost_per_claim - s.specialty_avg_cost_per_claim,
      s.specialty_avg_cost_per_claim),
    1) AS pct_above_specialty_avg,

  -- Simple outlier flag: >50% above specialty avg = review candidate
  CASE
    WHEN p.cost_per_claim > s.specialty_avg_cost_per_claim * 1.5
      THEN 'High Outlier — Review'
    WHEN p.cost_per_claim < s.specialty_avg_cost_per_claim * 0.7
      THEN 'Low Outlier — Efficient'
    ELSE 'Within Normal Range'
    END AS outlier_flag,

  -- Spend rank across all prescribers
  RANK()
    OVER (
      ORDER BY p.total_spend DESC
    ) AS spend_rank
FROM
  prescriber_spend p
LEFT JOIN
  specialty_avg s
  ON p.specialty = s.specialty
ORDER BY
  p.total_spend DESC;
