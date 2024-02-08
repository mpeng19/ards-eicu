CREATE OR REPLACE TABLE `hst-urop.ards.pfdata` AS
-- Extract PAO2 data
WITH PAO2_data AS (
  SELECT 
    patientunitstayid, 
    labresult AS pao2, 
    labresultoffset AS timestamp
  FROM `physionet-data.eicu_crd.lab`
  WHERE LOWER(labname) LIKE '%pao2%'
),

-- Extract FIO2 data
FIO2_data AS (
  SELECT 
    patientunitstayid, 
    SAFE_CAST(respchartvalue AS FLOAT64) / 100 AS fio2,  -- Casting to FLOAT64 and then dividing by 100
    respchartoffset AS timestamp
  FROM `physionet-data.eicu_crd.respiratorycharting`
  WHERE LOWER(respchartvaluelabel) LIKE '%fio2%'
),

-- Merge PAO2 and FIO2 data
merged_data AS (
  SELECT 
    COALESCE(p.patientunitstayid, f.patientunitstayid) AS patientunitstayid,
    p.pao2,
    f.fio2,
    CASE
      WHEN ABS(p.timestamp - f.timestamp) <= 120 THEN (p.timestamp + f.timestamp) / 2
      ELSE COALESCE(p.timestamp, f.timestamp)
    END AS merged_timestamp
  FROM PAO2_data p
  FULL OUTER JOIN FIO2_data f
  ON p.patientunitstayid = f.patientunitstayid
  AND ABS(p.timestamp - f.timestamp) <= 120
),

-- Add PF Ratio Calculation
final_data AS (
  SELECT *,
    CASE 
      WHEN pao2 IS NOT NULL AND fio2 IS NOT NULL AND fio2 > 0 THEN pao2 / fio2
      ELSE NULL
    END AS pf_ratio
  FROM merged_data
)

-- Select final output
SELECT 
  patientunitstayid, 
  pao2, 
  fio2, 
  merged_timestamp,
  pf_ratio
FROM final_data
ORDER BY patientunitstayid, merged_timestamp;



