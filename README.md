
# California Medicare Part D — Pharmacy Benefit Analytics

> End-to-end pharmacy analytics portfolio project using CMS Medicare Part D 2024 data.  
> Built to demonstrate PBM analytics skills for healthcare industry roles.

---

## Live Dashboard

**[View Dashboard 1 - Spend Analysis ](https://public.tableau.com/views/PharmacyDrugSpend-CaliforniaMedicarePartD/CAMedicarePartDAnalytics?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**  
**[View Dashboard 2 - Utilization & Outliers ](https://public.tableau.com/views/PharmacyDrugSpend-CaliforniaMedicarePartD/UtilizationOutliers?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**


---

## Headline Findings

| Finding | Number |
|---------|--------|
| Total CA Medicare drug spend analyzed | **$849.5M** |
| Generic substitution savings opportunity | **$594.9M** |
| Brand vs generic cost gap per claim | **23x** ($725 vs $31) |
| Generic dispensing rate vs 85% benchmark | **75.9%** (9.1pp gap) |
| Highest outlier prescriber above specialty avg | **4,526%** above avg |
| Drugs driving 80% of total spend | **Top 99 of 847** (11.7%) |
| GLP-1 drugs combined spend | **$77M** (Ozempic + Mounjaro + Trulicity + Rybelsus) |

---

## Project Overview

This project analyzes California Medicare Part D prescriber and drug spend data to identify cost drivers, utilization patterns, and savings opportunities - the core analytical work performed by Pharmacy Benefit Managers (PBMs) like MedImpact, CVS Caremark, and Express Scripts.

### Tools Used

| Tool | Purpose |
|------|---------|
| **Google BigQuery** | Data storage, cleaning, and all 10 SQL queries |
| **Tableau Public** | Interactive dashboard (2 dashboards, 9 views) |
| **CMS Medicare Part D 2024** | Source dataset |

### Skills Demonstrated

- Advanced BigQuery SQL (CTEs, window functions, SAFE_DIVIDE, COALESCE, NULLIF)
- PBM analytics concepts (GDR, specialty pharmacy, formulary management, utilization review)
- Prescriber outlier detection using specialty benchmarking
- Generic substitution savings modeling
- Medication adherence analysis (acute vs chronic drug distinction)
- Tableau Public dashboard design and publishing

---

## Dataset

**Source:** [CMS Medicare Part D Prescribers by Provider and Drug 2024](https://data.cms.gov/provider-summary-by-type-of-service/medicare-part-d-prescribers/medicare-part-d-prescribers-by-provider-and-drug)

**Scope:** California prescribers only (sample dataset)

| Metric | Value |
|--------|-------|
| Rows | 96,800 |
| Total drug spend | $849.5M |
| Total claims | 4.9M |
| Total patients | 1.4M |
| Unique drugs | 847 |
| Prescriber specialties | 77 |

**Clean table created in BigQuery:**  
`cms-medicare-prescriber-data.cms_medicare.partd_clean`

Key column renames from raw CMS data:

| Raw Column | Clean Name |
|-----------|-----------|
| Prscrbr_NPI | prescriber_npi |
| Tot_Drug_Cst | total_drug_cost |
| Tot_Clms | total_claims |
| Brnd_Name | drug_brand_name |
| Gnrc_Name | drug_generic_name |
| Tot_Benes | total_patients |
| Tot_Day_Suply | total_days_supply |
| Tot_30day_Fills | total_30day_fills |

---

## SQL Queries

All 10 queries are in the `/sql` folder. Each file is fully commented with business context.

| File | What it answers | Key finding |
|------|----------------|-------------|
| [row_count_and_data_snapshot.sql](sql/row_count_and_data_snapshot.sql) | Dataset snapshot - total spend, claims, patients | $849.5M spend,  4.9M claims,  96,800 prescribers |
| [top_20_drugs_by_spend.sql](sql/top_20_drugs_by_spend.sql) | Which drugs cost the most? | Eliquis #1 at $59.8M, top 20 = 44.7% of spend |
| [brand_vs_generic_gdr.sql](sql/brand_vs_generic_gdr.sql) | Brand vs generic split + GDR | Brand = 89% spend, Generic = 76% claims, 23x cost gap |
| [specialty_drug_detection.sql](sql/specialty_drug_detection.sql) | Which drugs cost >$1,000/claim? | Krystexxa $56,404/claim, Stelara $18M total |
| [prescriber_specialty.sql](sql/prescriber_specialty.sql) | Which doctor types drive spend? | 31 oncologists = $91M at $2.93M/prescriber |
| [prescriber_outlier_detection.sql](sql/prescriber_outlier_detection.sql) | Which prescribers are outliers? | NP Banty 4,526% above NP avg ($10,364 vs $224/claim) |
| [city_analysis.sql](sql/city_analysis.sql) | How does spend vary by city? | San Diego $170/claim - lowest in CA, 49% below SF |
| [generic_substitution_savings.sql](sql/generic_substitution_savings.sql) | How much could we save with generics? | **$594.9M** potential savings |
| [medication_adherence.sql](sql/medication_adherence.sql) | How well are patients taking their meds? | Generics 75+ days/fill vs brands 35-50 days |
| [executive_scorecard.sql](sql/executive_scorecard.sql) | Master table for Tableau dashboard | 847 drugs classified, top 99 = 80% of spend |

---

## SQL Concepts Used

| Concept | Where Used | What it does |
|---------|-----------|-------------|
| `WITH ... AS` (CTE) | prescriber_outlier_detection.sql, generic_substitution_savings | Builds intermediate named results before final SELECT |
| `RANK() OVER (ORDER BY ... DESC)` | top_20_drugs_by_spend.sql, prescriber_specialty.sql, city_analysis.sql, executive_scorecard.sql| Assigns spend rank across all drugs/specialties |
| `SUM(SUM(x)) OVER()` | top_20_drugs_by_spend.sql, brand_vs_generic_gdr.sql, prescriber_specialty.sql| Window function for % of total spend calculation |
| `SAFE_DIVIDE(a, b)` | All queries | Division that returns NULL instead of error on divide-by-zero |
| `COALESCE(a, b)` | generic_substitution_savings | Returns first non-NULL value - real generic price or 80% estimate |
| `NULLIF(x, 0)` | generic_substitution_savings | Returns NULL when value = 0, prevents divide-by-zero |
| `UPPER(TRIM(...))` | brand_vs_generic_gdr.sql, generic_substitution_savings | Normalizes text for case-insensitive comparison |
| `CASE WHEN ... THEN ... END` | specialty_drug_detection.sql, prescriber_specialty.sql, Q10 | Creates drug type, specialty, and adherence flag columns |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` | executive_scorecard.sql | Cumulative sum for Pareto chart |
| `HAVING` with aggregates | city_analysis.sql, medication_adherence.sql| Filters grouped results after GROUP BY |

---

## Dashboard Structure

### Dashboard 1 — Spend Analysis
- 5 KPI cards (Total Spend, Total Claims, Avg Cost/Claim, Savings Opportunity, GDR)
- Top 20 Drugs by Total Spend (bar chart, colored Brand vs Generic)
- Brand vs Generic Split — Claims (pie chart, 76% Generic)
- Brand vs Generic Split — Spend (pie chart, 89% Brand)
- Specialty Drug Analysis (horizontal bar, sorted by cost/claim)
- Prescriber Specialty table (ranked by spend, color-coded by cost tier)
- City Analysis table (CA cities, color by cost/claim)

### Dashboard 2 — Utilization & Outliers
- Prescriber Outlier Detection (table, flagged High/Normal/Efficient)
- Medication Adherence chart (chronic drugs, 30 + 80 day reference lines)
- Key Findings Summary

### Interactive Features
- Navigation buttons linking both dashboards
- Use as Filter on Top 20 bar chart (click drug → all sheets update)
- Drug Type dropdown filter (Brand/Generic)
- Specialty dropdown filter on Dashboard 2
- Highlight action on hover

---

## Key Business Insights

### 1. $594.9M Savings Opportunity
If brand drug claims were switched to generic equivalents, California Medicare alone could save $594.9M. At a realistic 30% substitution rate, that represents approximately $178M in achievable savings - the core value proposition of PBM generic substitution programs.

### 2. The Brand vs Generic Paradox
Brand drugs represent only 24% of claims but consume 89% of total drug spend - a 23x cost gap per claim ($725 brand vs $31 generic). California's Generic Dispensing Rate of 75.9% sits 9.1 percentage points below the 85% industry benchmark, representing a significant formulary optimization opportunity.

### 3. Specialty Drug Concentration
Top 99 drugs (11.7% of 847 total) drive 80% of all spend - confirming the Pareto principle in pharmacy benefits. Hematology-Oncology specialists (just 31 doctors) drive $91M in spend at $2.93M per prescriber - the highest of any specialty - entirely through specialty cancer drugs like Pomalyst ($22,917/claim) and Lenalidomide ($12,703/claim).

### 4. GLP-1 Drug Surge
Ozempic, Mounjaro, Trulicity, and Rybelsus combined represent $77M in spend - the fastest-growing drug class in the dataset. GLP-1 adherence (Ozempic: 36.7 days/fill, Mounjaro: 33.5 days/fill) sits just above the 30-day minimum, making this a high-priority care management target given the $1,000+/claim cost.

### 5. Prescriber Outlier Detection
16 of the top 25 prescribers by spend are flagged as high outliers. A Nurse Practitioner in West Hollywood prescribes at $10,364/claim - 4,526% above the NP specialty average of $224/claim. A rheumatologist in Sacramento prescribes 57% below the rheumatology average - a peer benchmarking opportunity for the PBM.

### 6. San Diego Market Insight
San Diego has the lowest cost per claim ($170) of any major California city - 49% below San Francisco ($336). This generic-driven prescribing pattern creates different formulary management priorities than Northern California markets and is particularly relevant for San Diego-based PBMs like MedImpact.

---

## Retail Finance -- Healthcare Translation

This project was built as a career transition portfolio from retail finance analytics. Key parallels:

| Retail Finance Concept | Healthcare/PBM Equivalent |
|-----------------------|--------------------------|
| Private label vs national brand mix | Generic Dispensing Rate (GDR) |
| Store-level variance vs comp average | Prescriber outlier detection |
| Regional performance benchmarking | City/geography cost analysis |
| Top SKU Pareto analysis | Top drug spend concentration |
| Basket size optimization | Days supply / adherence programs |
| Margin analysis | Cost per claim optimization |

---

## How to Reproduce This Project

### Prerequisites
- Google Cloud account (BigQuery free tier is sufficient)
- Tableau Public account (free)
- CMS Medicare Part D 2024 dataset downloaded

### Steps

1. **Download the dataset** from CMS.gov → filter to CA prescribers
2. **Load into BigQuery** → create dataset `cms_medicare` → upload as `partd_raw`
3. **Create the clean table** using the column rename script in `/data/create_partd_clean.sql`
4. **Run queries 1-10** in order → save each result as a BigQuery table
5. **Export CSVs** from BigQuery for prescriber_specialty.sql, prescriber_outlier_detection.sql, city_analysis.sql, medication_adherence.sql (needed as separate Tableau sources)
6. **Connect Tableau Public** → load executive_scorecard.csv as primary source
7. **Build dashboard** following the sheet structure in `/dashboard/`

---

## File Structure

```
medicare-partd-analytics/
├── README.md
├── sql/
│   ├── row_count_and_data_snapshot.sql
│   ├── top_20_drugs_by_spend.sql
│   ├── brand_vs_generic_gdr.sql
│   ├── specialty_drug_detection.sql
│   ├── prescriber_specialty.sql
│   ├── prescriber_outlier_detection.sql
│   ├── city_analysis.sql
│   ├── generic_substitution_savings.sql
│   ├── medication_adherence.sql
│   └── executive_scorecard.sql
├── dashboard/
│   └── dashboard_build_notes.md
├── data/
│   └── data_dictionary.md
└── images/
    └── dashboard_preview.png
```

---

**Connect:** [LinkedIn](https://www.linkedin.com/in/mrunalibharshankar/) · [Tableau Public](https://public.tableau.com/app/profile/mrunali.bharshankar)
