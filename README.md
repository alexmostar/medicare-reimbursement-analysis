# Medicare Inpatient Reimbursement Variation Analysis  
### PostgreSQL + Tableau Public

## Overview

This project analyzes **2023 Medicare inpatient hospital data** from the Centers for Medicare & Medicaid Services (CMS) to examine how Medicare payments vary across Diagnosis-Related Groups (DRGs), hospitals, and U.S. states.

The analysis uses **PostgreSQL** to validate and analyze **146,427 hospital-DRG records** representing:

- **2,945 hospitals**
- **534 MS-DRGs**
- **50 states and Washington, DC**

A major focus of the project was developing a reproducible method for selecting a DRG for geographic analysis rather than choosing one arbitrarily.

After evaluating hospital volume, discharge volume, geographic coverage, coefficient of variation, and robust payment variation, **MS-DRG 392 — Esophagitis, Gastroenteritis and Miscellaneous Digestive Disorders without MCC** was selected for the state-level analysis.

Tableau Public was then used to visualize state-level reimbursement differences, hospital-level payment variation, and the DRG-selection methodology.

---

## Live Tableau Dashboard

**[View the interactive Tableau dashboard](https://public.tableau.com/app/profile/alex.mostar7231/viz/Medicare_Reimbursement_DRG392_Dashboard/Dashboard)**

## Dashboard Preview

![Medicare Reimbursement Dashboard](images/Medicare_Dashboard.png)

---

## Research Questions

This project was designed to answer four primary questions:

1. Which DRGs show the greatest hospital-to-hospital variation in Medicare payments?
2. Which DRGs have sufficient hospital volume and geographic coverage for reliable comparison?
3. How can payment variation be measured without allowing a small number of extreme observations to dominate the analysis?
4. For a well-represented DRG, how do Medicare payments vary across U.S. states?

---

## Data Validation

Before performing the analysis, the raw CMS dataset was validated in PostgreSQL.

Key checks included:

- Confirming **146,427 total records**
- Identifying **2,945 unique hospitals**
- Identifying **534 unique DRGs**
- Confirming coverage across **51 state/DC areas**
- Checking for duplicate hospital-DRG combinations
- Reviewing minimum and maximum discharge counts
- Investigating unusually low and high Medicare payment observations

No duplicate hospital-DRG combinations were found.

The minimum discharge count was **11**, which is consistent with CMS suppression of hospital-DRG combinations with 10 or fewer discharges in the public dataset.

Extreme Medicare payment observations were reviewed rather than automatically removed. Because the dataset contains legitimate high-cost inpatient procedures and Medicare payment values can differ substantially across hospitals, extreme observations were retained unless there was evidence of a data-quality problem.

---

## DRG Selection Methodology

Rather than selecting a DRG before performing the analysis, all **534 DRGs** were evaluated using a structured screening process.

### 1. Hospital and Discharge Volume

For each DRG, PostgreSQL calculated:

- Number of reporting hospitals
- Number of states represented
- Total discharges
- Mean Medicare payment

### 2. Payment Variation

Hospital-level payment variation was measured using:

**Standard Deviation**

Measures the absolute spread of hospital-level Medicare payments within a DRG.

**Coefficient of Variation (CV)**

\[
CV = \frac{Standard\ Deviation}{Mean}
\]

CV allows variation to be compared across DRGs with substantially different average payment levels.

### 3. Geographic Coverage

State representation was evaluated more carefully than simply counting whether a DRG appeared in a state.

For each DRG, the analysis calculated the number of states with at least **three reporting hospitals**.

This prevented DRGs with only one or two hospitals in many states from appearing more geographically representative than they actually were.

### 4. Eligibility Criteria

DRGs were required to meet all three minimum thresholds:

- **200+ reporting hospitals**
- **3,000+ total discharges**
- **30+ states/DC areas with at least 3 reporting hospitals**

A total of **148 DRGs** passed these screening criteria.

### 5. Robust Variation Analysis

Initial rankings showed that some DRGs had very high CV values because of a small number of extreme payment observations.

To reduce the influence of outliers, the project also calculated the **Interquartile Range (IQR)** and **Relative IQR**.

\[
IQR = Q3 - Q1
\]

\[
Relative\ IQR = \frac{Q3-Q1}{Median}
\]

Relative IQR measures the spread of the middle 50% of hospital payments relative to the DRG's median payment.

This provides a more robust measure of typical hospital-to-hospital variation than CV alone.

### 6. Final Ranking

Eligible DRGs were ranked using the following priorities:

1. Prefer DRGs with at least three reporting hospitals across **all 51 state/DC areas**
2. Among those DRGs, rank by **Relative IQR**

Under this methodology, **MS-DRG 392 ranked first**.

---

## Why DRG 392?

### MS-DRG 392  
**Esophagitis, Gastroenteritis and Miscellaneous Digestive Disorders without MCC**

DRG 392 provided a strong combination of volume, geographic representation, and payment variation:

| Metric | Result |
|---|---:|
| Reporting Hospitals | **1,951** |
| Total Discharges | **86,037** |
| States/DC Represented | **51 / 51** |
| States/DC with 3+ Hospitals | **51 / 51** |
| Coefficient of Variation | **0.426** |
| Relative IQR | **0.303** |
| Final Selection Rank | **1** |

This made DRG 392 particularly well suited for a nationwide geographic comparison.

---

## State-Level Analysis

After selecting DRG 392, hospital records were aggregated by state.

Two state-level payment measures were calculated.

### Unweighted Average

```sql
AVG(avg_medicare_payment)
```

This gives each hospital equal influence regardless of its number of discharges.

### Discharge-Weighted Average

```sql
SUM(avg_medicare_payment * total_discharges)
/
SUM(total_discharges)
```

This gives hospitals with more DRG 392 discharges greater influence on the state average.

The **discharge-weighted average** was selected as the primary measure for the Tableau state map.

Because the CMS dataset contains hospital-level aggregate values rather than individual claims, this metric should be interpreted as a **discharge-weighted estimate based on hospital-level aggregates**, not a patient-level claim average.

---

## Key Findings

### DRG 392 had complete usable geographic coverage

DRG 392 was reported by **1,951 hospitals** and had at least three reporting hospitals in every state and Washington, DC.

This provided substantially stronger geographic coverage than many high-variation DRGs.

### State-level Medicare payments varied substantially

The national discharge-weighted average Medicare payment for DRG 392 was approximately:

**$5,481**

State-level weighted averages ranged from approximately:

- **$3,952 in Vermont**
- **$8,930 in Maryland**

The highest state average was therefore more than twice the lowest, demonstrating substantial geographic payment variation even when the DRG was held constant.

### Hospital-level payments were right-skewed

Most hospitals were concentrated within a relatively narrow payment range, while a smaller number of hospitals had substantially higher Medicare payments.

This right-skewed distribution demonstrated why robust measures such as Relative IQR were useful when comparing DRGs.

### The DRG with the highest CV was not automatically the best candidate

Some DRGs initially appeared highly variable because extreme observations increased their standard deviations and CV values.

Adding Relative IQR and geographic coverage requirements produced a more balanced and defensible selection methodology.

---

## Tableau Dashboard

The final Tableau dashboard includes:

- **Reporting Hospitals KPI**
- **Total Discharges KPI**
- **State/DC Coverage KPI**
- **National Weighted Average Medicare Payment KPI**
- **State-level choropleth map**
- **Alaska and Hawaii map insets**
- **Top 10 states by weighted Medicare payment**
- **Bottom 10 states by weighted Medicare payment**
- **Hospital-level Medicare payment distribution**
- **Top DRG candidates by Relative IQR**

The state map uses a diverging color scale centered on the national weighted average of approximately **$5,481**.

---

## SQL Workflow

The PostgreSQL analysis follows a reproducible pipeline:

### 1. Raw Data Setup

Created the PostgreSQL table used to store the CMS inpatient dataset while preserving identifiers such as DRG codes, provider CCNs, ZIP codes, and state FIPS codes as character fields where appropriate.

### 2. Data Quality Validation

Checked:

- Row counts
- Duplicate hospital-DRG combinations
- Numeric ranges
- Extreme Medicare payment observations
- Unique hospital, DRG, and state counts

### 3. DRG-Level Exploration

Calculated:

- Hospital count
- State coverage
- Total discharges
- Average Medicare payment

### 4. Payment Variation Analysis

Calculated:

- Standard deviation
- Coefficient of variation
- Median
- Q1 and Q3
- Interquartile range
- Relative IQR

### 5. Geographic Coverage Analysis

Calculated the number of reporting hospitals for every:

**DRG + State**

and identified the number of states with at least three reporting hospitals.

### 6. DRG Eligibility and Ranking

Applied volume and geographic-coverage requirements before ranking eligible DRGs using robust payment variation.

### 7. DRG 392 State Analysis

Calculated:

- Hospitals per state
- Total discharges
- Unweighted average Medicare payment
- Discharge-weighted average Medicare payment

### 8. Tableau Views

Created reusable PostgreSQL views:

- `drg_selection_summary`
- `drg392_state_summary`
- `drg392_hospital_detail`

These views were used to prepare the datasets used in Tableau.

---

## Tools Used

- **PostgreSQL** — data storage, validation, aggregation, and statistical analysis
- **pgAdmin** — PostgreSQL database management and query execution
- **Tableau Public** — interactive data visualization and dashboard development
- **GitHub** — project documentation and portfolio hosting

---

## Data Source

This project uses the **2023 Medicare Inpatient Hospitals by Provider and Service** dataset published by the Centers for Medicare & Medicaid Services (CMS).

The dataset contains hospital-level Medicare inpatient information organized by provider and MS-DRG.

The raw CMS dataset is publicly available and is not stored in this repository.

**CMS Data:**  
https://data.cms.gov/provider-summary-by-type-of-service/medicare-inpatient-hospitals/medicare-inpatient-hospitals-by-provider-and-service

---

## Repository Structure

```text
Medicare-Reimbursement-Analysis/
│
├── sql/
│   └── medicare_reimbursement_analysis.sql
│
├── tableau/
│   └── Medicare_Reimbursement_DRG392_Dashboard.twbx
│
├── images/
│   └── Medicare_Dashboard.png
│
└── README.md
```

---

## Limitations

Several limitations should be considered when interpreting the analysis:

- The CMS dataset contains **hospital-level aggregates**, not individual patient claims.
- Hospital-DRG combinations with **10 or fewer discharges are suppressed** in the public dataset.
- The discharge-weighted payment calculation is based on hospital-level average payments and discharge counts rather than individual claims.
- State-level payment differences may reflect factors such as hospital characteristics, Medicare payment adjustments, local wage differences, and case mix that are not directly modeled in this project.
- The analysis is **descriptive** and does not establish causal explanations for reimbursement differences.

---

## Project Significance

This project demonstrates an end-to-end healthcare analytics workflow using SQL and Tableau.

Key skills demonstrated include:

- Structuring and validating a large healthcare dataset in PostgreSQL
- Writing multi-stage SQL queries using CTEs, joins, aggregation, filtering, and window functions
- Developing reproducible analytical selection criteria
- Comparing variation using both conventional and robust statistical measures
- Calculating discharge-weighted reimbursement metrics
- Evaluating geographic coverage and sample size
- Translating complex SQL analysis into an interactive Tableau dashboard
- Communicating analytical methodology, findings, and limitations clearly

The project demonstrates how combining **data validation, statistical reasoning, SQL, and data visualization** can produce a more defensible analysis than simply ranking raw averages or selecting observations based on 
