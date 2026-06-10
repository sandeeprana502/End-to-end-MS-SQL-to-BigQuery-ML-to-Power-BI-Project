-- Training set 80%
CREATE OR REPLACE TABLE `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnTrain` AS
SELECT * FROM `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnFeatures`
WHERE MOD(CustomerKey, 10) < 8;

-- Eval set 20%
CREATE OR REPLACE TABLE `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnEval` AS
SELECT * FROM `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnFeatures`
WHERE MOD(CustomerKey, 10) >= 8;

-- Verify split
SELECT 'train' AS split, COUNT(*) AS rows
FROM `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnTrain`
UNION ALL
SELECT 'eval', COUNT(*)
FROM `crypto-hallway-459513-u2.adventageworkdw.CustomerChurnEval`;