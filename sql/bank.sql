--USE DATABASE BANKING_RAW;
--USE SCHEMA INSIGHTS;


--SELECT * FROM FDIC_INSTITUTIONS 
--LIMIT 5;

--SELECT * FROM FRED_FINANCIAL_LABOR_PERFORMANCE 
--LIMIT 5;


-- SETUP
CREATE DATABASE IF NOT EXISTS US_BANKING_DB;
USE DATABASE US_BANKING_DB;

CREATE SCHEMA IF NOT EXISTS STAGING; -- raw copies
CREATE SCHEMA IF NOT EXISTS DWH;     -- completed star schema



--SELECT * FROM BANKING_RAW.INSIGHTS.FDIC_INSTITUTIONS 
--LIMIT 10;

-- ============================================================

-- STAGING
USE SCHEMA STAGING;

CREATE OR REPLACE TABLE stg_fdic_institutions (

    stg_id INT IDENTITY(1,1) PRIMARY KEY, 
    bank_name   STRING,
    city        STRING,
    state       STRING,
    asset_amt   INT, -- money
    deposit_amt INT,
    est_date    DATE,
    website     STRING
);

INSERT INTO stg_fdic_institutions (bank_name,
city, state, asset_amt, deposit_amt,
est_date, website)
SELECT 
    MSA,        -- bank name
    CONSERVE,   -- city
    STALP,      -- state
    ADDRESS, -- assets
    DEPDOM,  -- deposits
    EQ,        -- date of found
    WEBADDR     -- site
FROM BANKING_RAW.INSIGHTS.FDIC_INSTITUTIONS
WHERE MSA IS NOT NULL 
  AND TRY_TO_NUMBER(ADDRESS) > 0;

-- SELECT * FROM stg_fdic_institutions;
-- SELECT count(*) FROM stg_fdic_institutions;

-- star schema Transform n load
-- DIMENSION
USE SCHEMA DWH;

-- geography
CREATE OR REPLACE TABLE DIM_GEO (
    geo_id INT IDENTITY(1,1) PRIMARY KEY,
    state_code STRING,
    city_name STRING
);

INSERT INTO DIM_GEO (state_code, city_name)
SELECT DISTINCT
    state,
    city
FROM STAGING.STG_FDIC_INSTITUTIONS WHERE state IS NOT NULL
ORDER BY state, city;

SELECT * FROM dim_geo LIMIT 5;

--Bank details
CREATE OR REPLACE TABLE DIM_BANK_DETAILS (
    bank_id INT PRIMARY KEY,
    name STRING,
    website STRING
);

INSERT INTO DIM_BANK_DETAILS (bank_id, name, website)
SELECT
    stg_id,
    bank_name,
    website
FROM STAGING.STG_FDIC_INSTITUTIONS;

SELECT * FROM dim_bank_details LIMIT 5;

--Date
CREATE OR REPLACE TABLE DIM_DATE (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    quarter INT,
    day_of_week INT,
    day_name string,
    month_name string
);

INSERT INTO DIM_DATE (full_date, year, month, quarter, day_of_week, day_name, month_name)
-- Temp table DATE_RANGE:
WITH DATE_RANGE AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS row_num     -- insert number in each row
    FROM TABLE(GENERATOR(ROWCOUNT => 55000))    -- 365 * 150 = 55000
)
SELECT
    DATEADD(DAY, row_num, '1900-01-01') as my_date,
    YEAR(my_date),
    MONTH(my_date),
    QUARTER(my_date),
    DAYOFWEEK(my_date),
    --day_name:
    DECODE(DAYOFWEEK(my_date), 0, 'Sunday', 1, 'Monday', 2, 'Tuesday', 3, 'Wednesdady', 4, 'Thursday', 5, 'Friday', 6, 'Saturday'),
    MONTHNAME(my_date)
FROM DATE_RANGE
WHERE my_date <= '2050-12-31';

select * from DIM_DATE limit 5;

-- facts

CREATE OR REPLACE TABLE fact_bank_perfomance (
    fact_id INT IDENTITY(1, 1) PRIMARY key,
    bank_id_fk INT,
    geo_id_fk INT,
    established_date_id_fk INT,
    total_assets INT,
    total_deposits INT,
    rank_in_state INT,
    avg_state_assets INT
);

INSERT INTO fact_bank_perfomance (
    bank_id_fk, geo_id_fk, established_date_id_fk, total_assets, total_deposits, rank_in_state, avg_state_assets
)
SELECT
    b.bank_id,
    g.geo_id,
    d.date_id,
    s.asset_amt,
    s.deposit_amt,
    RANK() OVER (PARTITION BY s.state ORDER BY s.asset_amt DESC),
    AVG(s.asset_amt) OVER (PARTITION BY s.state)
FROM
    STAGING.stg_fdic_institutions s
JOIN DIM_BANK_DETAILS b ON s.stg_id = b.bank_id
LEFT JOIN DIM_GEO g ON s.state = g.state_code and s.city = g.city_name
LEFT JOIN DIM_DATE d ON s.est_date = d.full_date;

SELECT * FROM fact_bank_perfomance LIMIT 5;


--cleaning
USE SCHEMA STAGING;
DROP TABLE IF EXISTS stg_fdic_institutions;
