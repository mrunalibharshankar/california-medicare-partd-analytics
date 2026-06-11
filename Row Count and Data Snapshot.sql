-- Row Count and Data Snapshot
SELECT
  COUNT(*) AS total_records,
  COUNT(DISTINCT prescriber_npi) AS unique_prescribers,
  COUNT(DISTINCT drug_generic_name) AS unique_drugs,
  SUM(total_claims) AS total_claims,
  ROUND(SUM(total_drug_cost), 2) AS total_drug_spend,
  SUM(total_patients) AS total_patients
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`;
