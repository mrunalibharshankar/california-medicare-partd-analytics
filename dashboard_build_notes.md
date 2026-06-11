# Dashboard Build Notes

## Data Sources Required

| Tableau Data Source | BigQuery Table | Used In |
|--------------------|---------------|---------|
| Executive_summary | cms_medicare.executive_scorecard | Dashboard 1 — all main views |
| top_prescribers | cms_medicare.top_prescribers | Prescriber Outlier sheet |
| city_analysis | cms_medicare.city_analysis | City Analysis sheet |
| Chronic_Drugs | cms_medicare.adherence | Medication Adherence sheet |

## Dashboard 1 — Spend Analysis

### Sheets
1. KPI — Total Spend (hardcoded calculated field: 849537596)
2. KPI — Total Claims (SUM of claims_filled)
3. KPI — Cost Per Claim (SUM(total_spend) / SUM(claims_filled))
4. KPI — Savings Opportunity (SUM(total_spend) * 0.70)
5. KPI — GDR (calculated: SUM generic claims / SUM all claims)
6. Top 20 Drugs by Spend (bar chart, filtered Top 20 by total_spend)
7. Brand vs Generic — Spend (pie, calculated field MIN aggregation)
8. Brand vs Generic — Claims (pie, calculated field MIN aggregation)
9. Specialty Drug Analysis (bar, filtered Specialty flag only)
10. Prescriber Specialty (text table, color by cost tier)
11. City Analysis (text table, color by cost per claim)

### Calculated Fields
- `Total Claims by Type`: IF [Drug Type] = 'Brand Medicine' THEN 1181530 ELSEIF [Drug Type] = 'Generic Medicine' THEN 3730244 END
- `Total Spend by Type`: IF [Drug Type] = 'Brand Medicine' THEN 755818235.10 ELSEIF [Drug Type] = 'Generic Medicine' THEN 93719360.91 END
- `Generic Dispensing Rate`: SUM(IF [Drug Type] = 'Generic Medicine' THEN [Claims Filled] END) / SUM([Claims Filled])
- `True Avg Cost Per Claim`: SUM([Total Spend]) / SUM([Claims Filled])
- `Specialty Tier`: IF [Cost Per Claim] > 1000 THEN 'High' ELSEIF [Cost Per Claim] > 300 THEN 'Mid' ELSE 'Low' END

## Dashboard 2 — Utilization & Outliers

### Sheets
1. Prescriber Outliers (text table, color by Outlier Flag)
2. Medication Adherence (bar chart, color by Adherence Flag)
3. Key Findings Summary (text annotation)

### Interactive Features
- Navigation button on Dashboard 1 → links to Dashboard 2
- Navigation button on Dashboard 2 → links back to Dashboard 1
- Top 20 Drugs bar chart → Use as Filter (funnel icon)
- Drug Type dropdown filter → Applied to all worksheets

## Color Coding (consistent across all sheets)
- Brand Medicine: Orange #D85A30
- Generic Medicine: Dark Blue #185FA5
- High Outlier: Red/Coral #712B13
- Low Outlier — Efficient: Blue #0C447C
- Good Adherence: Orange #D85A30
- Standard Adherence: Dark Blue #185FA5
