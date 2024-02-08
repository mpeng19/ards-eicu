CREATE OR REPLACE TABLE `hst-urop.ards.revised_pfdata` AS
WITH MinPFRatios AS (
  SELECT 
    patientunitstayid,
    MIN(pf_ratio) AS min_pf_ratio
  FROM `hst-urop.ards.pfdata`
  GROUP BY patientunitstayid
),
FirstLowPFRatio AS (
  SELECT 
    patientunitstayid,
    MIN(merged_timestamp) AS first_low_pf_ratio_timestamp
  FROM `hst-urop.ards.pfdata`
  WHERE pf_ratio <= 300
  GROUP BY patientunitstayid
)
SELECT 
  p.patientunitstayid,
  p.min_pf_ratio,
  MIN(d.merged_timestamp) AS first_observation,
  MAX(d.merged_timestamp) AS last_observation,
  MIN(CASE WHEN d.pf_ratio = p.min_pf_ratio THEN d.merged_timestamp END) AS min_pf_ratio_timestamp,
  f.first_low_pf_ratio_timestamp
FROM MinPFRatios p
JOIN `hst-urop.ards.pfdata` d ON p.patientunitstayid = d.patientunitstayid
LEFT JOIN FirstLowPFRatio f ON p.patientunitstayid = f.patientunitstayid
GROUP BY p.patientunitstayid, p.min_pf_ratio, f.first_low_pf_ratio_timestamp
ORDER BY p.patientunitstayid;

