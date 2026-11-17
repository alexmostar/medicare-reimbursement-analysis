-- Download the CMS dataset from the link provided in the README,
-- then replace the path below with the location of the CSV file.

-- Import CMS Medicare Inpatient Hospitals by Provider and Service dataset (2023)

TRUNCATE TABLE inpatient_drg_raw;

-- Update the path below to the location of the downloaded CMS dataset.
COPY inpatient_drg_raw
FROM 'path/to/MUP_INP_RY25_P03_V10_DY23_PrvSvc.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ENCODING 'WIN1252'
);

SELECT COUNT(*)
FROM inpatient_drg_raw;
