# Analysis of US Banking Institutions & Economic Trends 

This repository presents an end-to-end ELT (Extract, Load, Transform) project implemented in Snowflake. The goal was to transform raw, unstructured FDIC banking data into a structured Star Schema, which allows for analysis of the financial stability, geography, and historical growth of US banks. 

 

## 1. Introduction and Data Source 

The project analyses the financial reports of US banking institutions. The main objectives were to determine: 

* The ratio between bank assets and deposits. 

* Capital in different US states. 

* Historical trends in the creation of new banks (1800–2025). 

* The largest financial institutions. 

Key Dashboard:Below is the final analytical dashboard containing all key metrics.  

Source Data: The dataset comes from the Snowflake Marketplace "Banking Analytics Bundle". Originally, the data was unstructured and denormalized like a single flat table, with columns such as:  

* MSA (Bank Name)  

* STALP (State)  

* ADDRESS (Total Assets - stored as text)  

* DEPDOM (Total Deposits - stored as text)  

* EQ (Established Date - stored as text) 
