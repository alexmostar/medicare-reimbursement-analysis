/* ============================================================================
   Medicare Inpatient Payment Variability Analysis (2023)
   Core idea: identify DRGs with unusually high reimbursement dispersion
   across hospitals using standard deviation and coefficient of variation (CV).
   ============================================================================ */

-- 0) Quick sanity check: overall variability exists
SELECT
  COUNT(*) AS n_rows,
  ROUND(AVG(avg_medicare_payment)::numeric, 2) AS avg_payment_overall,
  ROUND(STDDEV_POP(avg_medicare_payment::float8)::numeric, 2) AS stddev_pop_overall,
  ROUND(STDDEV_SAMP(avg_medicare_payment::float8)::numeric, 2) AS stddev_samp_overall
FROM inpatient_drg;

-- 1) DRGs with highest absolute payment variability (std dev)
-- Note: group by drg_code only (descriptions can vary slightly across rows)
SELECT
  drg_code,
  MIN(drg_description) AS drg_description,
  COUNT(*) AS hospital_count,
  ROUND(AVG(avg_medicare_payment)::numeric, 2) AS avg_payment,
  ROUND(STDDEV_SAMP(avg_medicare_payment::float8)::numeric, 2) AS stddev_payment
FROM inpatient_drg
GROUP BY drg_code
HAVING COUNT(*) >= 20
ORDER BY stddev_payment DESC
LIMIT 15;

-- 2) DRGs with highest relative payment variability (coefficient of variation)
-- CV = stddev / mean
SELECT
  drg_code,
  MIN(drg_description) AS drg_description,
  COUNT(*) AS hospital_count,
  ROUND(AVG(avg_medicare_payment)::numeric, 2) AS avg_payment,
  ROUND(STDDEV_SAMP(avg_medicare_payment::float8)::numeric, 2) AS stddev_payment,
  ROUND(
    (STDDEV_SAMP(avg_medicare_payment::float8) /
     NULLIF(AVG(avg_medicare_payment::float8), 0))::numeric
  , 3) AS cv
FROM inpatient_drg
GROUP BY drg_code
HAVING COUNT(*) >= 20
ORDER BY cv DESC
LIMIT 15;

-- 3) CV with an additional volume filter to reduce noise
-- (filters rows where provider-DRG discharges are very low)
SELECT
  drg_code,
  MIN(drg_description) AS drg_description,
  COUNT(*) AS hospital_count,
  ROUND(AVG(avg_medicare_payment)::numeric, 2) AS avg_payment,
  ROUND(STDDEV_SAMP(avg_medicare_payment::float8)::numeric, 2) AS stddev_payment,
  ROUND(
    (STDDEV_SAMP(avg_medicare_payment::float8) /
     NULLIF(AVG(avg_medicare_payment::float8), 0))::numeric
  , 3) AS cv
FROM inpatient_drg
WHERE total_discharges >= 20
GROUP BY drg_code
HAVING COUNT(*) >= 20
ORDER BY cv DESC
LIMIT 15;

-- 4) Drilldown: distribution for a single DRG (replace '306' as needed)
-- Useful once you pick your "featured" DRG from the CV list.
SELECT
  provider_name,
  state,
  total_discharges,
  ROUND(avg_medicare_payment, 2) AS avg_medicare_payment,
  ROUND(avg_submitted_charge, 2) AS avg_charge,
  ROUND(charge_to_medicare_ratio, 2) AS charge_to_medicare_ratio
FROM inpatient_drg
WHERE drg_code = '306'
ORDER BY avg_medicare_payment DESC
LIMIT 50;

-- 5) Optional: compare variability by rural vs urban using RUCA description
-- This groups RUCA into a simple bucket using text patterns.
WITH ruca_bucket AS (
  SELECT
    *,
    CASE
      WHEN ruca_desc ILIKE '%Metropolitan%' THEN 'Metropolitan'
      WHEN ruca_desc ILIKE '%Micropolitan%' THEN 'Micropolitan'
      WHEN ruca_desc ILIKE '%Small town%' THEN 'Small town'
      WHEN ruca_desc ILIKE '%Rural%' THEN 'Rural'
      ELSE 'Other/Unknown'
    END AS ruca_group
  FROM inpatient_drg
)
SELECT
  ruca_group,
  COUNT(*) AS n_rows,
  ROUND(AVG(avg_medicare_payment)::numeric, 2) AS avg_payment,
  ROUND(STDDEV_SAMP(avg_medicare_payment::float8)::numeric, 2) AS stddev_payment
FROM ruca_bucket
GROUP BY ruca_group
ORDER BY avg_payment DESC;

-- Hospital-level variation for DRG 196 (Interstitial Lung Disease with MCC)

SELECT
  provider_name,
  state,
  total_discharges,
  ROUND(avg_medicare_payment,2) AS avg_medicare_payment,
  ROUND(avg_submitted_charge,2) AS avg_charge,
  ROUND(charge_to_medicare_ratio,2) AS charge_to_medicare_ratio
FROM inpatient_drg
WHERE drg_code = '196'
ORDER BY avg_medicare_payment DESC;

SELECT
  MIN(avg_medicare_payment) AS min_payment,
  MAX(avg_medicare_payment) AS max_payment,
  ROUND(MAX(avg_medicare_payment) - MIN(avg_medicare_payment),2) AS payment_range
FROM inpatient_drg
WHERE drg_code = '196';

-- Average payment for DRG 196 by state

SELECT
  state,
  COUNT(*) AS hospital_count,
  ROUND(AVG(avg_medicare_payment),2) AS avg_payment
FROM inpatient_drg
WHERE drg_code = '196'
GROUP BY state
ORDER BY avg_payment DESC;
