SELECT
  precision,
  recall,
  accuracy,
  f1_score,
  roc_auc
FROM ML.EVALUATE(
  MODEL `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnModel`,
  (SELECT * FROM `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnEval`)
);