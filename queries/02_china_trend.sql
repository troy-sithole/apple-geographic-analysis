WITH china_data AS (
  SELECT
    fiscal_year,
    revenue_usd_billions AS china_revenue_billions,
    LAG(revenue_usd_billions) OVER (ORDER BY fiscal_year) AS prev_year_revenue_billions
  FROM `apple-geographic-analysis.sec_edgar_raw.apple_geographic_revenue`
  WHERE region = 'Greater China'
)
SELECT
  fiscal_year,
  china_revenue_billions,
  prev_year_revenue_billions,
  ROUND((china_revenue_billions - prev_year_revenue_billions) / prev_year_revenue_billions * 100, 2) AS yoy_growth_pct
FROM china_data
ORDER BY fiscal_year;