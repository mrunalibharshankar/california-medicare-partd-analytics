-- Executive Summary Scorecard
SELECT
  drug_brand_name,
  drug_generic_name,

  -- volume
  sum(total_claims) AS claims_filled,
  Round(sum(total_drug_cost), 2) AS total_spend,

  -- unit cost
  round(safe_divide(sum(total_drug_cost), sum(total_claims)), 2)
    AS cost_per_claim,

  -- brand vs generic classification
  CASE
    WHEN
      drug_brand_name IS NULL
      OR upper(trim(drug_brand_name)) = upper(trim(drug_generic_name))
      THEN 'Generic Medicine'
    ELSE 'Brand Medicine'
    END AS drug_type,

  -- specialty drug flag (>$1000/claim)
  CASE
    WHEN Safe_divide(sum(total_drug_cost), sum(total_claims)) > 1000
      THEN 'Specialty'
    ELSE 'Standard'
    END AS specialty_flag,

  -- Adherence tier from supply
  CASE
    WHEN safe_divide(sum(total_days_supply), sum(total_claims)) >= 80
      THEN '90-days supply'
    WHEN safe_divide(sum(total_days_supply), sum(total_claims)) >= 25
      THEN '30-days supply'
    ELSE 'Short fill'
    END AS supply_tier,

  -- spend rank
  rank() OVER (ORDER BY sum(total_drug_cost) DESC) AS spend_rank,

  -- % of total spend
  round(100 * sum(total_drug_cost) / sum(sum(total_drug_cost)) OVER (), 2)
    AS percent_of_total_spend,

  -- Cumulative spend %
  round(
    100.0 * sum(sum(total_drug_cost))
      OVER (
        ORDER BY sum(total_drug_cost) DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      )
      / sum(sum(total_drug_cost)) OVER (),
    1) AS cumulative_spend_pct
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
GROUP BY 1, 2
HAVING sum(total_claims) >= 100
ORDER BY 4 DESC;
