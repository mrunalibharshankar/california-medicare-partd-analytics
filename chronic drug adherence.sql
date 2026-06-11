-- Chronic drug adherence only
-- Uses avg days supply per patient as adherence signal
-- Industry benchmark: chronic drugs should have 270+ days/year
-- Below 180 days = adherence risk = hidden cost driver

SELECT
  drug_brand_name,
  drug_generic_name,
  sum(total_claims) AS Claims_filled,
  round(sum(total_drug_cost), 2) AS total_spend,
  round(safe_divide(sum(total_drug_cost), sum(total_claims)), 2)
    AS cost_per_claim,
  sum(total_days_supply) AS total_days_supplied,
  round(safe_divide(sum(total_days_supply), sum(total_claims)), 1)
    AS avg_days_per_fill,
  -- Average fills per year proxy
  -- A 30-day drug filled 12x = good adherence
  -- A 30-day drug filled 4x = poor adherence
  round(safe_divide(SUM(total_claims), SUM(total_30day_fills)), 1)
    AS fill_frequency_ratio,
  -- Adherence flag based on avg days per fill
  CASE
    WHEN SAFE_DIVIDE(SUM(total_days_supply), SUM(total_claims)) >= 80
      THEN 'Good — 90-day supply'
    WHEN SAFE_DIVIDE(SUM(total_days_supply), SUM(total_claims)) >= 25
      THEN 'Standard — 30-day supply'
    ELSE 'Short fill — adherence risk'
    END AS adherence_flag,
  -- % of total spend
  round(100.0 * SUM(total_drug_cost) / SUM(SUM(total_drug_cost)) OVER (), 2)
    AS percent_of_total_spend
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
GROUP BY 1, 2
HAVING
  sum(total_claims) >= 1000
  AND Safe_divide(sum(total_days_supply), sum(total_claims)) > 14
  -- only include drugs with avg fill >14 days
  -- This filters out vaccines (1-3 days) and antibiotics (5-10 days)
  AND LOWER(drug_generic_name) NOT LIKE '%vaccine%'
  AND LOWER(drug_generic_name) NOT LIKE '%vacc%'
  AND LOWER(drug_generic_name) NOT LIKE '%antigen%'
  AND LOWER(drug_generic_name) NOT LIKE '%toxoid%'
  AND LOWER(drug_generic_name) NOT LIKE '%peg3350%'
  AND sum(total_days_supply) > 0
ORDER BY avg_days_per_fill ASC;
