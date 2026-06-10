CREATE OR REPLACE TABLE `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnPredictions` AS

SELECT
  f.CustomerKey,
  c.FirstName,
  c.LastName,
  c.EmailAddress,
  f.recency_days,
  f.order_count,
  f.total_spend,
  f.country,
  f.occupation,

  -- Predicted label
  p.predicted_churned,

  -- Churn probability score
  ROUND(
    (SELECT prob FROM UNNEST(p.predicted_churned_probs)
     WHERE label = 'Churned'), 4
  ) AS churn_probability,

  -- Risk tier for Power BI slicer
  CASE
    WHEN (SELECT prob FROM UNNEST(p.predicted_churned_probs)
          WHERE label = 'Churned') >= 0.75 THEN 'High Risk'
    WHEN (SELECT prob FROM UNNEST(p.predicted_churned_probs)
          WHERE label = 'Churned') >= 0.40 THEN 'Medium Risk'
    ELSE 'Low Risk'
  END AS churn_risk_tier

FROM ML.PREDICT(
  MODEL `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnModel`,
  (
    SELECT * EXCEPT(churned)
    FROM `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnFeatures`
  )
) p
JOIN `crypto-hallway-459513-u2.adventageworkdw.DimCustomer` c
  ON p.CustomerKey = c.CustomerKey
JOIN `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnFeatures` f
  ON p.CustomerKey = f.CustomerKey;