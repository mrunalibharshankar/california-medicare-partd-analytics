-- Prescriber Specialty Analysis
-- Which Doctor types drive the most spend and the cost per claim?

SELECT
  prescriber_specialty AS Prescriber_Type,
  COUNT(DISTINCT prescriber_npi) AS Unique_prescriber,
  sum(total_claims) AS Total_Claims,
  sum(total_patients) AS Total_Patients,
  Round(sum(total_drug_cost), 2) AS Total_Spend,
  ROUND(SAFE_DIVIDE(SUM(total_drug_cost), SUM(total_claims)), 2)
    AS cost_per_claim,
  ROUND(SAFE_DIVIDE(SUM(total_drug_cost), SUM(total_patients)), 2)
    AS cost_per_patient,
  ROUND(SAFE_DIVIDE(SUM(total_drug_cost), COUNT(DISTINCT prescriber_npi)), 2)
    AS Spend_per_prescriber,
  Round(100 * sum(total_drug_cost) / sum(sum(total_drug_cost)) OVER (), 2)
    AS Percent_of_total_spend,
  Rank() OVER (ORDER BY sum(total_drug_cost) DESC) AS Spend_Rank
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
WHERE prescriber_specialty IS NOT NULL AND TRIM(prescriber_specialty) != ''
GROUP BY 1
ORDER BY Spend_Rank;
