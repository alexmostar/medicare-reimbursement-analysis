-- Import CMS Medicare Inpatient Provider and Service dataset (2023)

TRUNCATE TABLE inpatient_drg_raw;

COPY inpatient_drg_raw
FROM 'C:\\Users\\alexm\\Downloads\\MUP_INP_RY25_P03_V10_DY23_PrvSvc.CSV'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ENCODING 'WIN1252'
);