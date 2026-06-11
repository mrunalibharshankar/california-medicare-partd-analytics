-- Generic Substitution Savings Model
-- Estimates dollar savings if brand drugs were switched to their generic equivalent


--Aggerate brand drugs(brand name differs from generic drug name)
CREATE OR REPLACE TABLE `cms-medicare-prescriber-data.cms_medicare.savings_model` AS 
With brand_summary as (
SELECT
drug_generic_name,
drug_brand_name,
sum(total_claims) as Brand_Claims,
Round(sum(total_drug_cost),2) as brand_Spend,
Round(SAFE_DIVIDE(sum(total_drug_cost),sum(total_claims)), 2)  as brand_cost_per_claim
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
where drug_brand_name is not NULL and upper(trim(drug_brand_name)) != upper(trim(drug_generic_name))
group by 1, 2),

generic_summary as(
-- aggregate generic drugs (brand name = generic name or NULL)
SELECT
drug_generic_name,
Round(SAFE_DIVIDE(sum(total_drug_cost),sum(total_claims)), 2)  as generic_cost_per_claim
FROM `cms-medicare-prescriber-data.cms_medicare.partd_clean`
where drug_brand_name is NULL and upper(trim(drug_brand_name)) = upper(trim(drug_generic_name))
group by 1)

-- Join Brand_summary to Generic_summary and calculate savings per drug

SELECT
  b.drug_brand_name AS brand_name,
  b.drug_generic_name AS generic_ingredient,
  b.Brand_Claims,
  b.brand_Spend,
  b.brand_cost_per_claim,
  coalesce(g.generic_cost_per_claim, round(b.brand_cost_per_claim * 0.20, 2)) as generic_cost_per_claim,
  case when g.generic_cost_per_claim is not null then 'Real Generic Price' else 'Estimated (80% discount assumed)' end as price_source,
  round(b.Brand_Claims * (b.brand_cost_per_claim - Coalesce(g.generic_cost_per_claim, b.brand_cost_per_claim * 0.20)),2) as estimated_savings,
  round(100* ( b.brand_cost_per_claim - Coalesce(g.generic_cost_per_claim, b.brand_cost_per_claim * 0.20))/Nullif(b.brand_cost_per_claim,0),1) 
  as savings_percent
  from brand_summary b
  left join generic_summary g on upper(trim(b.drug_generic_name)) = upper(trim(g.drug_generic_name))
  where b.brand_spend > 100000

  order by estimated_savings desc;









