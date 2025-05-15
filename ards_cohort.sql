DROP TABLE IF EXISTS `hst-urop.ards.cohort`;
CREATE TABLE `hst-urop.ards.cohort` AS
WITH MaxPEEP AS (
  SELECT
    rc.patientunitstayid,
    MAX(CASE WHEN rc.respchartvaluelabel = 'PEEP' THEN rc.respchartvalue END) AS max_peep
  FROM
    `physionet-data.eicu_crd.respiratorycharting` AS rc
  WHERE
    rc.respchartentryoffset >= 480  
  GROUP BY
    rc.patientunitstayid
),
ICD9Codes AS (
  SELECT
    d.patientunitstayid,
    STRING_AGG(DISTINCT d.icd9code, '|') AS icd9code_list
  FROM
    `physionet-data.eicu_crd.diagnosis` AS d
  WHERE
     REGEXP_CONTAINS(d.icd9code, r'518\.[0-8]') AND NOT REGEXP_CONTAINS(d.icd9code, r'428')
  GROUP BY
    d.patientunitstayid
)
SELECT
  rpd.patientunitstayid,
  rpd.min_pf_ratio AS pf_ratio,
  mp.max_peep,
  icd.icd9code_list,
  CASE WHEN rpd.min_pf_ratio IS NOT NULL AND rpd.min_pf_ratio <= 300 THEN 1 ELSE 0 END ||
  CASE WHEN mp.max_peep IS NOT NULL AND CAST(mp.max_peep AS FLOAT64) >= 5 THEN 1 ELSE 0 END ||
  CASE WHEN icd.icd9code_list IS NOT NULL THEN 1 ELSE 0 END AS indicator
FROM
  `hst-urop.ards.revised_pfdata` AS rpd
LEFT JOIN
  MaxPEEP AS mp ON rpd.patientunitstayid = mp.patientunitstayid
LEFT JOIN
  ICD9Codes AS icd ON rpd.patientunitstayid = icd.patientunitstayid
WHERE
  CONCAT(CASE WHEN rpd.min_pf_ratio IS NOT NULL AND rpd.min_pf_ratio <= 300 THEN '1' ELSE '0' END,
         CASE WHEN mp.max_peep IS NOT NULL AND CAST(mp.max_peep AS FLOAT64) >= 5 THEN '1' ELSE '0' END,
         CASE WHEN icd.icd9code_list IS NOT NULL THEN '1' ELSE '0' END) != '000';

