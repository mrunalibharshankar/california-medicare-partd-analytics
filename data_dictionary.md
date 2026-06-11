# Data Dictionary

## Source: CMS Medicare Part D Prescribers by Provider and Drug 2024
Download: https://data.cms.gov/provider-summary-by-type-of-service/medicare-part-d-prescribers/medicare-part-d-prescribers-by-provider-and-drug

## Clean Table: cms_medicare.partd_clean

| Column Name (clean) | Original CMS Column | Data Type | Description |
|--------------------|--------------------|-----------| ------------|
| prescriber_npi | Prscrbr_NPI | STRING | National Provider Identifier — unique doctor ID |
| prescriber_last_or_org_name | Prscrbr_Last_Org_Name | STRING | Doctor last name or organization name |
| prescriber_first_name | Prscrbr_First_Name | STRING | Doctor first name |
| prescriber_city | Prscrbr_City | STRING | City where prescriber practices |
| prescriber_state | Prscrbr_State_Abrvtn | STRING | State (all CA in this dataset) |
| prescriber_specialty | Prscrbr_Type | STRING | Medical specialty (77 unique values) |
| drug_brand_name | Brnd_Name | STRING | Brand name of the drug (e.g. Eliquis) |
| drug_generic_name | Gnrc_Name | STRING | Generic/chemical name (e.g. Apixaban) |
| total_claims | Tot_Clms | INTEGER | Total number of Part D claims filled |
| total_patients | Tot_Benes | INTEGER | Total unique Medicare patients |
| total_drug_cost | Tot_Drug_Cst | FLOAT | Total drug cost in USD |
| total_days_supply | Tot_Day_Suply | INTEGER | Total days of medication supplied |
| total_30day_fills | Tot_30day_Fills | FLOAT | Number of 30-day equivalent fills |
| total_claims_65plus | GE65_Tot_Clms | INTEGER | Claims for patients 65+ |
| total_patients_65plus | GE65_Tot_Benes | INTEGER | Patients aged 65+ |
| total_drug_cost_65plus | GE65_Tot_Drug_Cst | FLOAT | Drug cost for patients 65+ |

## Notes
- Rows with fewer than 11 patients per drug are suppressed by CMS for privacy
- Suppressed rows show NULL for patient count but may still show claim counts
- drug_brand_name = drug_generic_name indicates a generic drug dispensed
- drug_brand_name IS NULL also indicates a generic drug

## Key Derived Metrics

| Metric | Formula | Description |
|--------|---------|-------------|
| Cost Per Claim | total_drug_cost / total_claims | Average cost per prescription fill |
| Generic Dispensing Rate | Generic claims / Total claims | % of claims filled as generic |
| Brand vs Generic | UPPER(brand_name) != UPPER(generic_name) | Drug type classification |
| Specialty Drug Flag | cost_per_claim > $1,000 | High-cost specialty drug indicator |
| Adherence Proxy | total_days_supply / total_claims | Average days supply per fill |
