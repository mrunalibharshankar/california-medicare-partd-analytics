-- Geographic Analysis — Spend by Cities in CA

SELECT
  prescriber_city AS City,
  COUNT(DISTINCT prescriber_npi) AS Unique_prescriber,
  COUNT(DISTINCT drug_generic_name) AS Unique_drugs,
  sum(total_claims) AS Total_Claims,
  Round(sum(total_drug_cost), 2) AS Total_Spend,
  ROUND(SAFE_DIVIDE(SUM(total_drug_cost), SUM(total_claims)), 2)
    AS cost_per_claim,
  ROUND(SAFE_DIVIDE(SUM(total_drug_cost), SUM(total_patients)), 2)
    AS cost_per_patient,
  ROUND(SAFE_DIVIDE(SUM(total_drug_cost), COUNT(DISTINCT prescriber_npi)), 0)
    AS Avg_claims_per_prescriber,
  Round(100 * sum(total_drug_cost) / sum(sum(total_drug_cost)) OVER (), 2)
    AS Percent_of_total_spend,
  Rank() OVER (ORDER BY sum(total_drug_cost) DESC) AS Spend_Rank
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
WHERE prescriber_city IS NOT NULL AND trim(prescriber_city) != ''
GROUP BY 1
ORDER BY Total_Spend DESC;
