WITH regional_boundaries AS (
  SELECT
    region,
    MAX(CASE WHEN fiscal_year = 2021 THEN revenue_usd_billions END) AS revenue_2021,
    MAX(CASE WHEN fiscal_year  = 2025 THEN revenue_usd_billions END) AS revenue_2025
  FROM `apple-geographic-analysis.sec_edgar_raw.apple_geographic_revenue`
  WHERE fiscal_year IN (2021, 2025)
  GROUP BY region
)
SELECT
  region,
  ROUND(revenue_2021, 3) AS revenue_2021_billions,
  ROUND(revenue_2025, 3) AS revenue_2025_billions,
  ROUND(revenue_2025 - revenue_2021, 3) AS absolute_growth_billions,
  ROUND(((revenue_2025 - revenue_2021) / revenue_2021) * 100, 2) AS total_growth_percent
FROM regional_boundaries
ORDER BY absolute_growth_billions DESC;