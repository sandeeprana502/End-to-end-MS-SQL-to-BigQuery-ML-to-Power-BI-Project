CREATE OR REPLACE TABLE `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnFeatures` AS

WITH customer_orders AS (
  SELECT
    f.CustomerKey,
    COUNT(DISTINCT f.SalesOrderNumber)                    AS order_count,
    SUM(f.SalesAmount)                                    AS total_spend,
    AVG(f.SalesAmount)                                    AS avg_order_value,
    MAX(d.FullDateAlternateKey)                           AS last_order_date,
    MIN(d.FullDateAlternateKey)                           AS first_order_date,
    DATE_DIFF(
      MAX(d.FullDateAlternateKey),
      MIN(d.FullDateAlternateKey), DAY
    )                                                     AS customer_tenure_days,
    COUNT(DISTINCT d.CalendarYear)                        AS active_years
  FROM `crypto-hallway-459513-u2.adventageworkdw.FactInternetSales` f
  JOIN `crypto-hallway-459513-u2.adventageworkdw.DimDate` d
    ON f.OrderDateKey = d.DateKey
  GROUP BY f.CustomerKey
),

customer_profile AS (
  SELECT
    c.CustomerKey,
    CAST(c.YearlyIncome AS FLOAT64)     AS yearly_income,
    c.TotalChildren                      AS total_children,
    c.NumberChildrenAtHome               AS children_at_home,
    c.EnglishEducation                   AS education,
    c.EnglishOccupation                  AS occupation,
    c.HouseOwnerFlag                     AS house_owner,
    c.NumberCarsOwned                    AS cars_owned,
    c.Gender                             AS gender,
    g.EnglishCountryRegionName           AS country
  FROM `crypto-hallway-459513-u2.adventageworkdw.DimCustomer` c
  LEFT JOIN `crypto-hallway-459513-u2.adventageworkdw.DimGeography` g
    ON c.GeographyKey = g.GeographyKey
),

ref_date AS (
  SELECT MAX(FullDateAlternateKey) AS max_date
  FROM `crypto-hallway-459513-u2.adventageworkdw.DimDate`
  WHERE DateKey IN (
    SELECT DISTINCT OrderDateKey
    FROM `crypto-hallway-459513-u2.adventageworkdw.FactInternetSales`
  )
)

SELECT
  o.CustomerKey,

  -- RFM features
  DATE_DIFF(r.max_date, o.last_order_date, DAY)   AS recency_days,
  o.order_count,
  ROUND(o.total_spend, 2)                          AS total_spend,
  ROUND(o.avg_order_value, 2)                      AS avg_order_value,
  o.customer_tenure_days,
  o.active_years,

  -- Customer profile
  p.yearly_income,
  p.total_children,
  p.children_at_home,
  p.education,
  p.occupation,
  p.house_owner,
  p.cars_owned,
  p.gender,
  p.country,

  -- Churn label (target column)
  CASE
    WHEN DATE_DIFF(r.max_date, o.last_order_date, DAY) > 365
    THEN 'Churned'
    ELSE 'Active'
  END AS churned

FROM customer_orders o
JOIN customer_profile p USING (CustomerKey)
CROSS JOIN ref_date r;