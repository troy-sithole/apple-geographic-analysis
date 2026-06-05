WITH geo_shock AS (
  -- 1. Calculating actual vs shocked total revenue for 2025
  SELECT
    SUM(revenue_usd_billions) AS actual_total_rev,
    SUM(CASE
          when region = 'Greater China' THEN revenue_usd_billions * 0.80
          ELSE revenue_usd_billions
        END) AS shocked_total_revenue
  FROM `apple-geographic-analysis.sec_edgar_raw.apple_geographic_revenue`
  WHERE fiscal_year = 2025
),
segments_2025 AS (
  -- 2. pulling baseline products/services gross profit performance
  SELECT
    SUM(revenue_usd_billions) AS total_segment_revenue,
    SUM(gross_profit_usd_billions) AS total_segment_gp
  FROM `apple-geographic-analysis.sec_edgar_raw.apple_segment_revenue`
  WHERE fiscal_year = 2025
)
SELECT
  ROUND(g.actual_total_rev, 3) AS actual_2025_revenue_billions,
  ROUND(g.shocked_total_revenue, 3) AS shocked_2025_revenue_billions,
  ROUND(g.shocked_total_revenue - g.actual_total_rev, 3) AS net_revenue_impact_billions,
  ROUND(((g.shocked_total_revenue - g.actual_total_rev) / g.actual_total_rev) * 100, 2) AS revenue_pct_drop,

  -- 3. Evaluating the margin thesis
  -- Since China shocks primarily hit hardware supply lines and regional device sales,
  -- I modelled the revenue haircut against Apple's total corporate margin baseline.
  ROUND((s.total_segment_gp / s.total_segment_revenue) * 100, 2) AS baseline_corporate_gross_margin_pct,
  ROUND((s.total_segment_gp / g.shocked_total_revenue) * 100, 2) AS post_shock_corporate_gross_margin_pct,
FROM geo_shock g
CROSS JOIN segments_2025 s;