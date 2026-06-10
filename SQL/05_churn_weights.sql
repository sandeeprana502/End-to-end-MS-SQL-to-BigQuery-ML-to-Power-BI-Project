SELECT
  processed_input,
  weight
FROM ML.WEIGHTS(
  MODEL `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnModel`
)
ORDER BY ABS(weight) DESC
LIMIT 10;