-- Brand vs Generic spilt
-- Generic brand drugs contains same active ingredients as Brand name Drugs but cost 80%-85% less on Average.
-- Calculating generic dispensing rate(GDR)
-- Categorise drug type into 'Brand' and 'Generic'

SELECT
  -- Generic = brand name is NULL, blank, or identical to generic name
  -- Brand  = brand name exists and differs from generic name
  CASE
    WHEN Upper(trim(drug_brand_name)) = Upper(trim(drug_generic_name))
      THEN 'Generic'
    WHEN drug_brand_name IS NULL THEN 'Generic'
    WHEN trim(drug_brand_name) = '' THEN 'Generic'
    ELSE 'Brand'
    END AS drug_type,
  COUNT(DISTINCT drug_generic_name) AS unique_drug_name,
  Sum(total_claims) AS Total_claims,
  sum(total_patients) AS Total_Patients,
  round(sum(total_drug_cost), 2) AS Total_spend,
  round(Avg(safe_divide(total_drug_cost, total_claims)), 2)
    AS avg_cost_per_claim,
  -- Generic dispensing rate(GDR) shown as % of total claims
  round(100 * sum(total_claims) / sum(sum(total_claims)) OVER (), 1)
    AS percent_of_total_claims,
  round(100 * sum(total_drug_cost) / sum(sum(total_drug_cost)) OVER (), 1)
    AS percent_of_total_drug_spend,
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
GROUP BY drug_type
ORDER BY Total_spend DESC;
