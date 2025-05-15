DROP TABLE IF EXISTS `hst-urop.Neuroblock.duration`;

CREATE OR REPLACE TABLE `hst-urop.Neuroblock.duration` AS
WITH DrugIntervals AS (
  SELECT
    io.patientunitstayid,
    io.drugname,
    io.infusionoffset AS start_time,
    LEAD(io.infusionoffset) OVER (PARTITION BY io.patientunitstayid, io.drugname ORDER BY io.infusionoffset) AS end_time
  FROM `physionet-data.eicu_crd.infusiondrug` io
  WHERE LOWER(io.drugname) LIKE '%vecuronium%' OR
        LOWER(io.drugname) LIKE '%rocuronium%' OR
        LOWER(io.drugname) LIKE '%pancuronium%' OR
        LOWER(io.drugname) LIKE '%atracurium%' OR
        LOWER(io.drugname) LIKE '%cisatracurium%' OR
        LOWER(io.drugname) LIKE '%succinylcholine%'
),
FilteredDrugIntervals AS (
  SELECT
    di.patientunitstayid,
    di.drugname,
    di.start_time,
    di.end_time
  FROM DrugIntervals di
  WHERE di.end_time IS NOT NULL
)
SELECT
  fdi.patientunitstayid,
  fdi.drugname,
  ARRAY_AGG(STRUCT(fdi.start_time, fdi.end_time)) AS intervals
FROM FilteredDrugIntervals fdi
GROUP BY fdi.patientunitstayid, fdi.drugname;

