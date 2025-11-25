--Exploratory data analysis// just to understand my data
SELECT
  *
FROM
  "CAR"."SALES"."SALESDATA";

 -- EXPLORING DATA
 --NUMBER OF CARS SOLD
 SELECT MAKE, MODEL,
 COUNT(*) AS Quantity_sold
 FROM
  "CAR"."SALES"."SALESDATA"
  GROUP BY MAKE,model
  ORDER BY Quantity_sold desc;

  --Checking duplicates
  SELECT 
    Vin, 
    year,make, model, sellingprice,
    COUNT(*) as record_count
FROM 
    "CAR"."SALES"."SALESDATA"
GROUP BY  
    all-- Include all columns that make up your unique key
HAVING 
    record_count > 1
ORDER BY 
    record_count DESC;

--CHECKING NULL VALUES
SELECT VIN
FROM
  "CAR"."SALES"."SALESDATA"
  WHERE VIN IS NULL;

  --CHECKING NULL VALUES ON MAKE
SELECT MAKE
FROM
  "CAR"."SALES"."SALESDATA"
  WHERE MAKE IS NULL;
  ----CHECKING NULL VALUES ON MODEL
  SELECT MODEL
FROM
  "CAR"."SALES"."SALESDATA"
  WHERE MODEL IS NULL;
  --CHECKING NULL VALUES ON Transmission
  SELECT transmission, trim, color, condition, odometer, body
FROM
  "CAR"."SALES"."SALESDATA"
  WHERE transmission IS NULL OR TRIM IS NULL OR color IS NULL OR CONDITION IS NULL OR ODOMETER IS NULL OR BODY IS NULL;
  --
  SELECT
  COUNT (DISTINCT vin) AS Total_cars_sold
FROM
  "CAR"."SALES"."SALESDATA";
  -- counting units sold
  SELECT make, model,
  COUNT (*) AS units_sold
FROM
  "CAR"."SALES"."SALESDATA"
  group by make, model;
  --Checking first day of operation
  SELECT
  MIN(SALEDATE) AS first_operation_date
FROM
  "CAR"."SALES"."SALESDATA";
  --Checking last date of operation
  SELECT
  MAX(SALEDATE) AS Last_operation_date
FROM
  "CAR"."SALES"."SALESDATA";
  --CHECKING DIFFERENTS transmission types
  SELECT DISTINCT transmission
FROM
  "CAR"."SALES"."SALESDATA"
;
--CHECKING DIFFERENTS sellers types
SELECT DISTINCT SELLER
FROM
  "CAR"."SALES"."SALESDATA"
;
  --CHECKING DIFFERENTS STATES
  SELECT DISTINCT STATE
FROM
  "CAR"."SALES"."SALESDATA"
;
  -- CHECKING DIFFERENT YEAR MODELS
  SELECT DISTINCT YEAR
FROM
  "CAR"."SALES"."SALESDATA"
  WHERE YEAR >= '2000'
;
  SELECT 
    Vin, 
    year,make, model,
    COUNT(*) as record_count
FROM 
    "CAR"."SALES"."SALESDATA"
GROUP BY  
    all-- Include all columns that make up your unique key
HAVING 
    record_count > 1
ORDER BY 
    record_count DESC;
 -- ==========================================================================================
  DELETE FROM "CAR"."SALES"."SALESDATA" AS t
USING (
    SELECT 
        Vin -- Column(s) that define uniqueness
        ,year,make,model,saledate,-- columns to match on in the WHERE clause
        ROW_NUMBER() OVER (
            PARTITION BY VIN
            ORDER BY SALEDATE DESC -- Order to keep the 'best' record
        ) AS row_num
    FROM "CAR"."SALES"."SALESDATA"
    QUALIFY row_num > 1 -- Selects all but the 'best' record
) AS duplicates_to_delete
WHERE t.Vin = duplicates_to_delete.vin
  AND t.year = duplicates_to_delete.year AND t.make = duplicates_to_delete.make AND t.model = duplicates_to_delete.model
  AND t.saledate = duplicates_to_delete.saledate
  ;
-- calculating profit
SELECT
SELLINGPRICE-MMR AS profit
FROM
  "CAR"."SALES"."SALESDATA"
  order by profit asc
;
-- CONVERTING TIMESTAMPT TO YYYY-MM-DD FORMAT AND GROUPING TRANSSATIONS IN QUARTERS
    SELECT
    COALESCE(Vin, 'N/A') AS Vin,
    COALESCE(saledate,'2015-01-01') AS Saledate,
    TO_TIMESTAMP_NTZ(SALEDATE,'DY MON DD YYYY HH24:MI:SS') AS Sale_date,
    MONTHNAME (Sale_date) as month_name,
    year AS Year_Model,
    COALESCE(make, 'Unknown') AS Make,
    COALESCE(model, 'Unknown') AS Model,
    COALESCE(transmission, 'Unknown') AS Transmission,
    COALESCE(state, 'Unknown') AS State,
    COALESCE(color,'Unknown') AS Color,
    COALESCE(odometer, 0) AS Odometer,
    COALESCE(seller, 'Unknown') AS Seller,
    COALESCE(mmr, 0) AS MMR,
    COUNT(*) AS Quantity_sold,
    COALESCE(sellingprice, 0) AS Sellingprice,
    --estimated revenues as on quantity sold column each row represent a single sale
sum (SELLINGPRICE)AS TOTAL_REVENUE,
CASE 
WHEN month_name IN ('Jan','Feb','Mar') Then 'Quarter1'
WHEN month_name IN ('Apr','May','Jun') Then 'Quarter2'
WHEN month_name IN ('Jul','Aug','Sep') Then 'Quarter3'
WHEN month_name IN ('Oct','Nov','Dec') Then 'Quarter4'
END AS quarter_of_year
FROM
  "CAR"."SALES"."SALESDATA"
  GROUP BY all
  ORDER BY SELLINGPRICE DESC
;

