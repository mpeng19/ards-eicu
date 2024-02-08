# ICU_Queries
This project aims to identify patients from the eICU Collaborative Research Database who have been treated with neuromuscular blockers (NMBs) and intersect this group with a cohort of patients diagnosed with Acute Respiratory Distress Syndrome (ARDS). The goal is to facilitate research into treatment patterns, outcomes, and potential insights into the management of ARDS patients receiving NMBs.

## How to run this project

### 1. Get Access to MIMIC and eICU

Both MIMIC and eICU data can be found in [PhysioNet](https://physionet.org/), a repository of freely-available medical research data, managed by the MIT Laboratory for Computational Physiology. Due to its sensitive nature, credentialing is required to access both datasets.

Documentation for MIMIC-IV's can be found [here](https://mimic.mit.edu/) and for eICU [here](https://eicu-crd.mit.edu/).

### 2. Running queries

The project consists of two main SQL queries:

**Finding patients with ARDS** Run all the queries in the ards_cohort folder, in the order pfdata -> revisedpfdata -> ards_cohort. You will need access to physionet on google bigquery in order to run these queries. As shown below, create your own project in BigQuery and replace the corresponding names.
```
CREATE OR REPLACE TABLE `[YOUR PROJECT NAME].[YOUR DATABASE NAME].pfdata` AS
-- Extract PAO2 data
WITH PAO2_data AS (
  SELECT 
    patientunitstayid, 
    labresult AS pao2, 
    labresultoffset AS timestamp
  FROM `physionet-data.eicu_crd.lab`
  WHERE LOWER(labname) LIKE '%pao2%'
)
```

**Extracting Patients Treated with NMBs:** This query retrieves patients from the eICU database who have been administered neuromuscular blockers during their ICU stay. It selects relevant patient identifiers, medication details, and administration times. Assuming you have a predefined list or table of ARDS patients, the intersection.sql query finds the intersection of patients treated with NMBs and those in your ARDS cohort.
