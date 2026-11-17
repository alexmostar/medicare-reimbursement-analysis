-- Top 10 DRGs by average Medicare payment (national)

SELECT
  drg_code,
  MIN(drg_description) AS drg_description,
  COUNT(*) AS hospital_count,
  ROUND(AVG(avg_medicare_payment)::numeric, 2) AS national_avg_medicare_payment
FROM inpatient_drg
GROUP BY drg_code
HAVING COUNT(*) >= 10
ORDER BY national_avg_medicare_payment DESC
LIMIT 10;

-- Top 10 states by average Medicare payment per DRG row

SELECT
  state,
  COUNT(*) AS row_count,
  ROUND(AVG(avg_medicare_payment)::numeric, 2) AS avg_medicare_payment
FROM inpatient_drg
GROUP BY state
HAVING COUNT(*) >= 50
ORDER BY avg_medicare_payment DESC
LIMIT 10;

-- Hospitals with highest charge-to-Medicare ratios
-- Filter out very low discharge counts to reduce noise

SELECT
  provider_name,
  state,
  drg_code,
  total_discharges,
  ROUND(avg_submitted_charge, 2) AS avg_charge,
  ROUND(avg_medicare_payment, 2) AS avg_medicare_payment,
  ROUND(charge_to_medicare_ratio, 2) AS charge_to_medicare_ratio
FROM inpatient_drg
WHERE total_discharges >= 20
ORDER BY charge_to_medicare_ratio DESC
LIMIT 25;