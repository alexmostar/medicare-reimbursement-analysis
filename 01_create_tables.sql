-- Drop existing raw table if it exists
DROP TABLE IF EXISTS inpatient_drg_raw;

-- Create raw table for CMS inpatient DRG data
CREATE TABLE inpatient_drg_raw (
  Rndrng_Prvdr_CCN text,
  Rndrng_Prvdr_Org_Name text,
  Rndrng_Prvdr_City text,
  Rndrng_Prvdr_St text,
  Rndrng_Prvdr_State_FIPS text,
  Rndrng_Prvdr_Zip5 text,
  Rndrng_Prvdr_State_Abrvtn text,
  Rndrng_Prvdr_RUCA text,
  Rndrng_Prvdr_RUCA_Desc text,
  DRG_Cd text,
  DRG_Desc text,
  Tot_Dschrgs integer,
  Avg_Submtd_Cvrd_Chrg numeric,
  Avg_Tot_Pymt_Amt numeric,
  Avg_Mdcr_Pymt_Amt numeric
);