# Analysis of US Banking Institutions & Economic Trends 

This repository presents an end-to-end ELT (Extract, Load, Transform) project implemented in Snowflake. The goal was to transform raw, unstructured FDIC banking data into a structured Star Schema, which allows for analysis of the financial stability, geography, and historical growth of US banks.  

## 1. Introduction and Data Source 

The project analyses the financial reports of US banking institutions. The main objectives were to determine: 

* The ratio between bank assets and deposits. 

* Capital in different US states. 

* Historical trends in the creation of new banks (1800–2025). 

* The largest financial institutions. 

**Key Dashboard:**

Below is the final analytical dashboard containing all key metrics.


![Final Dashboard](img/dashboard.jpg)

Source Data: The dataset comes from the Snowflake Marketplace "Banking Analytics Bundle". Originally, the data was unstructured and denormalized like a single flat table, with columns such as:  

*  `MSA` (Bank Name)  
* `STALP` (State)  
* `ADDRESS` (Total Assets - stored as text)  
* `DEPDOM` (Total Deposits - stored as text)  
* `EQ` (Founding Date - stored as text)


### 1.1 Data architecture (ERD)


**Raw data (source):**

The source data existed in a ‘flat’ format typical for raw extracts, which required cleaning.

![Source ERD](img/erd_schema.jpg)

*Figure 1: Source Entity-Relationship Diagram (Raw Flat Structure)*

---

## 2. Dimensional Model

To support efficient analytics, a Star Schema was designed. The model consists of one Fact table and three Dimension tables:

* `FACT_BANK_PERFORMANCE`: The central table containing metrics (Assets, Deposits) and foreign keys. It also includes calculated window functions like `Rank_In_State`.
* `DIM_BANK_DETAILS`: Descriptive attributes of the bank (Name, Website).
* `DIM_GEO`: Geographic hierarchy (State code, City name).
* `DIM_DATE`: Calendar attributes taken from the establishment date (Year, Quarter, Month).

![Star Schema](img/star_schema.jpg)

*Figure 2: Star Schema Optimized for Analytics)*

---

