CREATE OR REPLACE TABLE `hst-urop.Neuroblock.neuroblock` AS
WITH drugs AS (
  SELECT DISTINCT
    patientunitstayid,
    MAX(IF(drugname = 'succinylcholine', CONCAT(drugorderoffset, '_', drugstartoffset, '_', drugstopoffset, '_', dosage, '_', frequency), NULL)) AS succinylcholine,
    MAX(IF(drugname = 'rocuronium', CONCAT(drugorderoffset, '_', drugstartoffset, '_', drugstopoffset, '_', dosage, '_', frequency), NULL)) AS rocuronium,
    MAX(IF(drugname = 'vecuronium', CONCAT(drugorderoffset, '_', drugstartoffset, '_', drugstopoffset, '_', dosage, '_', frequency), NULL)) AS vecuronium,
    MAX(IF(drugname = 'atracurium', CONCAT(drugorderoffset, '_', drugstartoffset, '_', drugstopoffset, '_', dosage, '_', frequency), NULL)) AS atracurium,
    MAX(IF(drugname = 'cisatracurium', CONCAT(drugorderoffset, '_', drugstartoffset, '_', drugstopoffset, '_', dosage, '_', frequency), NULL)) AS cisatracurium,
    MAX(IF(drugname = 'mivacurium', CONCAT(drugorderoffset, '_', drugstartoffset, '_', drugstopoffset, '_', dosage, '_', frequency), NULL)) AS mivacurium
  FROM
    `physionet-data.eicu_crd.medication`
  GROUP BY
    patientunitstayid
)
SELECT
  *,
  CONCAT(
    IF(succinylcholine IS NOT NULL, '1', '0'),
    IF(rocuronium IS NOT NULL, '1', '0'),
    IF(vecuronium IS NOT NULL, '1', '0'),
    IF(atracurium IS NOT NULL, '1', '0'),
    IF(cisatracurium IS NOT NULL, '1', '0'),
    IF(mivacurium IS NOT NULL, '1', '0')
  ) AS indicator
FROM
  drugs;
DELETE FROM `hst-urop.Neuroblock.neuroblock`
WHERE indicator = '000000';
