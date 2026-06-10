CREATE OR REPLACE MODEL `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnModel`
OPTIONS (
  model_type         = 'LOGISTIC_REG',
  input_label_cols   = ['churned'],
  max_iterations     = 20,
  l2_reg             = 0.1,
  auto_class_weights = TRUE,
  data_split_method  = 'NO_SPLIT'
) AS
SELECT
  recency_days,
  order_count,
  total_spend,
  avg_order_value,
  customer_tenure_days,
  active_years,
  yearly_income,
  total_children,
  children_at_home,
  education,
  occupation,
  house_owner,
  cars_owned,
  gender,
  country,
  churned
FROM `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnTrain`;