-- Specialty Drug Detection using cost_per_claim

SELECT
  brand_drug_name,
  generic_drug_name,
  total_claims,
  total_spend,
  cost_per_claim,

  -- Flag specialty drugs: >$1,000/claim is the PBM industry threshold
  CASE
    WHEN cost_per_claim > 1000 THEN 'Specialty'
    ELSE 'Standard'
    END AS specialty_flag,

  -- % of total spend this drug represents
  ROUND(
    100.0 * total_spend / SUM(total_spend) OVER (), 2) AS percent_of_total_spend
FROM
  (
    SELECT
      drug_brand_name AS brand_drug_name,
      drug_generic_name AS generic_drug_name,
      SUM(total_claims) AS total_claims,
      ROUND(SUM(total_drug_cost), 2) AS total_spend,
      ROUND(
        SAFE_DIVIDE(
          SUM(total_drug_cost),  -- sum total spend for this drug
          SUM(total_claims)  -- divide by total claims for this drug
        ),
        2) AS cost_per_claim
    FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
    GROUP BY
      drug_brand_name,
      drug_generic_name
  )
ORDER BY cost_per_claim DESC
LIMIT 30;

SELECT
  drug_brand_name AS brand_drug_name,
  drug_generic_name AS generic_drug_name,
  sum(total_patients) AS Total_Patients,
  sum(total_claims) AS Total_claims,
  round(sum(total_drug_cost), 2) AS Total_spend,
  -- Annual cost per patient — specialty drugs
  round(safe_divide(sum(total_drug_cost), sum(total_patients)), 2)
    AS Cost_per_patients,
  -- Cost per Claims
  round(safe_divide(sum(total_drug_cost), sum(total_claims)), 2)
    AS cost_per_claim,
  -- Claim per Patients
  round(safe_divide(sum(total_claims), sum(total_patients)), 2)
    AS claims_per_patients,
  CASE
    WHEN sum(safe_divide(total_drug_cost, total_patients)) > 1000
      THEN 'Speciality'
    ELSE 'Standard'
    END AS speciality_flag
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
GROUP BY 1, 2
ORDER BY Cost_per_patients DESC;
