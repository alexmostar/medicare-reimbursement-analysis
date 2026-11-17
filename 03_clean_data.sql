-- Create cleaned analysis table with readable column names

DROP TABLE IF EXISTS inpatient_drg;

CREATE TABLE inpatient_drg AS
SELECT
  Rndrng_Prvdr_CCN AS provider_ccn,
  Rndrng_Prvdr_Org_Name AS provider_name,
  Rndrng_Prvdr_City AS city,
  Rndrng_Prvdr_St AS street_address,
  Rndrng_Prvdr_State_FIPS AS state_fips,
  Rndrng_Prvdr_Zip5 AS zip5,
  Rndrng_Prvdr_State_Abrvtn AS state,
  Rndrng_Prvdr_RUCA AS ruca_code,
  Rndrng_Prvdr_RUCA_Desc AS ruca_desc,
  DRG_Cd AS drg_code,
  DRG_Desc AS drg_description,
  Tot_Dschrgs AS total_discharges,
  Avg_Submtd_Cvrd_Chrg AS avg_submitted_charge,
  Avg_Tot_Pymt_Amt AS avg_total_payment,
  Avg_Mdcr_Pymt_Amt AS avg_medicare_payment,
  (Avg_Submtd_Cvrd_Chrg / NULLIF(Avg_Mdcr_Pymt_Amt, 0)) AS charge_to_medicare_ratio
FROM inpatient_drg_raw;