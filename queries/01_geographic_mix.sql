SELECT
  fiscal_year,
  region,
  revenue_usd_billions,
  SUM(revenue_usd_billions) OVER (PARTITION BY fiscal_year) AS total_revenue_usd_billions,
  ROUND (revenue_usd_billions / SUM(revenue_usd_billions) OVER (PARTITION BY fiscal_year) * 100, 2) AS revenue_share_pct
FROM `apple-geographic-analysis.sec_edgar_raw.apple_geographic_revenue`
ORDER BY fiscal_year, revenue_share_pct DESC;