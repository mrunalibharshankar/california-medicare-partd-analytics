-- Top 20 drugs by spend

select * from `cms-medicare-prescriber-data.cms_medicare.partd_clean`;

Select drug_brand_name as Drug_Brand_Name,
drug_generic_name as Generic_Drug_Name,
sum(total_claims) as Total_claims,
sum(total_patients) as Total_Patients,
round(sum(total_drug_cost),2) as Total_Drug_cost,
round(sum(total_drug_cost)/ nullif(sum(total_claims),0),2) as Cost_per_claim

 from `cms-medicare-prescriber-data.cms_medicare.partd_clean`
 group by Drug_Brand_Name, Generic_Drug_Name
 order by Total_Drug_cost desc
 limit 20;