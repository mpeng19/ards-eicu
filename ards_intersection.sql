-- Create the new table 'intersection_med_treatment' if it doesn't exist
CREATE OR REPLACE TABLE `hst-urop.Neuroblock.ards_intersection` AS
SELECT DISTINCT a.patientunitstayid
FROM `hst-urop.Neuroblock.neuroblock` a
INNER JOIN `hst-urop.ards.cohort` b
ON a.patientunitstayid = b.patientunitstayid
