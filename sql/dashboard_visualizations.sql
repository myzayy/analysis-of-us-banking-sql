-- Finance map of USA
SELECT 
    g.state_code AS State,
    SUM(f.total_assets) AS Total_Assets
FROM fact_bank_perfomance f
JOIN DIM_GEO g ON f.geo_id_fk = g.geo_id
GROUP BY g.state_code
ORDER BY Total_Assets DESC
LIMIT 15;

-- 10 Richest banks
SELECT b.name as Bank_name,
SUM(f.total_assets) as Total_assets
From FACT_BANK_PERFOMANCE f
JOIN dim_bank_details b ON f.bank_id_fk = b.bank_id
GROUP BY b.name ORDER BY TOTAL_ASSETS DESC LIMIT 10;

-- Bank system history
SELECT d.year AS Year_of_Found, COUNT(f.bank_id_fk) AS New_Banks_account
FROM fact_bank_perfomance f
JOIN dim_date d ON f.established_date_id_fk = d.date_id
WHERE d.year >= 1800 and d.year <= 2025
GROUP BY d.year
ORDER By d.year;

-- Assets VS Deposits
SELECT f.total_assets AS Assets,
    f.total_deposits AS Deposits,
    g.state_code AS State
FROM fact_bank_perfomance f
JOIN dim_geo g ON f.geo_id_fk = g.geo_id
WHERE f.total_assets < 100000
LIMIT 1000;

-- 10 states by avg bank size
SELECT DISTINCT g.state_code AS State,
f.avg_state_assets AS Average_bank_size
FROM fact_bank_perfomance f
JOIN dim_geo g ON f.geo_id_fk = g.geo_id
order by Average_bank_size DESC
LIMIT 10;

-- financial volume
SELECT 
    d.year,
    SUM(f.total_assets) as total_assets_money,
    
FROM FACT_BANK_PERFOMANCE f
JOIN DIM_DATE d ON f.established_date_id_fk = d.DATE_ID -- join by est date
WHERE d.year >= 2000 -- last 20 years
GROUP BY d.year
ORDER BY d.year;

-- bank creating activity
SELECT 
    d.year, 
    COUNT(f.fact_id) as banks_count,
FROM FACT_BANK_PERFOMANCE f
JOIN DIM_DATE d ON f.established_date_id_fk = d.DATE_ID -- join by est date
WHERE d.year >= 2000 -- last 20 years
GROUP BY d.year
ORDER BY d.year;
