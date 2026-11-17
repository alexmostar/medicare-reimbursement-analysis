/* ============================================================================
   Medicare Inpatient Payment Variability Analysis (2023)

   This analyzes Medicare reimbursement variation across DRGs, hospitals,
   and states using standard deviation and coefficient of variation (CV).
   It also creates summary tables used in the Tableau dashboard.
============================================================================ */

-- ============================================================================
-- 1. DRGs with the highest payment variability (Standard Deviation)
-- ============================================================================

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

-- ============================================================================
-- 2. DRGs with the highest relative variability (Coefficient of Variation)
-- ============================================================================

DROP TABLE IF EXISTS drg_payment_variability;

CREATE TABLE drg_payment_variability AS
SELECT
    drg_code,
    MIN(drg_description) AS drg_description,
    COUNT(*) AS hospital_count,
    ROUND(AVG(avg_medicare_payment)::numeric, 2) AS avg_payment,
    ROUND(STDDEV_SAMP(avg_medicare_payment::float8)::numeric, 2) AS stddev_payment,
    ROUND(
        (
            STDDEV_SAMP(avg_medicare_payment::float8) /
            NULLIF(AVG(avg_medicare_payment::float8), 0)
        )::numeric,
        3
    ) AS cv
FROM inpatient_drg
WHERE total_discharges >= 20
GROUP BY drg_code
HAVING COUNT(*) >= 20
ORDER BY cv DESC;

SELECT *
FROM drg_payment_variability
ORDER BY cv DESC
LIMIT 15;

-- ============================================================================
-- 3. Hospital-level reimbursement for DRG 196
-- ============================================================================

DROP TABLE IF EXISTS drg_196_hospital_payment;

CREATE TABLE drg_196_hospital_payment AS
SELECT
    provider_name,
    state,
    total_discharges,
    ROUND(avg_medicare_payment, 2) AS avg_medicare_payment,
    ROUND(avg_submitted_charge, 2) AS avg_charge,
    ROUND(charge_to_medicare_ratio, 2) AS charge_to_medicare_ratio
FROM inpatient_drg
WHERE drg_code = '196'
ORDER BY avg_medicare_payment DESC;

SELECT *
FROM drg_196_hospital_payment
LIMIT 15;

-- ============================================================================
-- 4. State-level average reimbursement for DRG 196
-- States with fewer than three reporting hospitals can be identified using
-- the hospital_count column when interpreting results.
-- ============================================================================

DROP TABLE IF EXISTS drg_196_state_payment;

CREATE TABLE drg_196_state_payment AS
SELECT
    state,
    COUNT(*) AS hospital_count,
    ROUND(AVG(avg_medicare_payment), 2) AS avg_payment
FROM inpatient_drg
WHERE drg_code = '196'
GROUP BY state
ORDER BY avg_payment DESC;

SELECT *
FROM drg_196_state_payment
ORDER BY avg_payment DESC;

