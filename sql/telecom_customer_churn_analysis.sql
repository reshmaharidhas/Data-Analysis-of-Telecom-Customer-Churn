SELECT * FROM telecom_customer_churn;

CREATE TABLE telecom_customer_churn_cleaned AS SELECT * FROM telecom_customer_churn;

SELECT * FROM telecom_customer_churn_cleaned;

-- Checking datatype of columns
SHOW COLUMNS FROM telecom_customer_churn_cleaned;  -- 20 columns

-- Number of rows
SELECT COUNT(*) FROM telecom_customer_churn_cleaned;  -- 7032 rows

-- Checking for Null values
SELECT * FROM telecom_customer_churn_cleaned 
WHERE 
gender IS NULL OR 
SeniorCitizen IS NULL OR 
Partner IS NULL OR 
Dependents IS NULL OR 
tenure IS NULL OR 
PhoneService IS NULL OR 
MultipleLines IS NULL OR 
InternetService IS NULL OR 
OnlineSecurity IS NULL OR 
OnlineBackup IS NULL OR 
DeviceProtection IS NULL OR 
TechSupport IS NULL OR 
StreamingTV IS NULL OR 
StreamingMovies IS NULL OR 
Contract IS NULL OR PaperlessBilling IS NULL;   -- No NULL values.

-- Checking inconsistencies 
SELECT gender,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY gender;  -- 3483 Female, 3549 Male
SELECT SeniorCitizen,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY SeniorCitizen;  -- 0,1
SELECT Partner,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY Partner;  -- No, Yes
SELECT distinct(Dependents) FROM telecom_customer_churn_cleaned; -- No, Yes 
SELECT distinct(PhoneService) FROM telecom_customer_churn_cleaned;  -- No, Yes
SELECT distinct(MultipleLines) FROM telecom_customer_churn_cleaned;  -- No phone service, No, Yes
SELECT InternetService,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY InternetService;  -- DSL, Fiber optic, No
SELECT DISTINCT(OnlineSecurity) FROM telecom_customer_churn_cleaned;  -- No, Yes, No internet service
SELECT DISTINCT(OnlineBackup) FROM telecom_customer_churn_cleaned;  -- No, Yes, No internet service
SELECT DISTINCT(DeviceProtection) FROM telecom_customer_churn_cleaned;  -- No, Yes, No internet service
SELECT DISTINCT(TechSupport) FROM telecom_customer_churn_cleaned;  -- No, Yes, No internet service
SELECT DISTINCT(StreamingTV) FROM telecom_customer_churn_cleaned;  -- No, Yes, No internet service
SELECT DISTINCT(StreamingMovies) FROM telecom_customer_churn_cleaned;  -- No, Yes, No internet service
SELECT Contract,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY Contract;  -- Month-to-month, One year, Two year
SELECT DISTINCT(PaperlessBilling) FROM telecom_customer_churn_cleaned;   -- Yes, No
SELECT PaymentMethod,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY PaymentMethod;  
/*
Electronic check	2365
Mailed check	1604
Bank transfer (automatic)	1542
Credit card (automatic)	1521
*/
SELECT Churn,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY Churn;
/*
No	5163
Yes	1869
*/
SELECT MIN(tenure),MAX(tenure),AVG(tenure) FROM telecom_customer_churn_cleaned;
/*
minimum=1 month, maximum=72 months,avg=32.42 months
*/
SELECT MIN(MonthlyCharges),MAX(MonthlyCharges) FROM telecom_customer_churn_cleaned;
/*
minimum=18.25, maximum=118.75 
*/
SELECT MIN(TotalCharges),MAX(TotalCharges) FROM telecom_customer_churn_cleaned;
/*
minimum=18.8, maximum=8684.8
*/

-- Data Cleaning
ALTER TABLE telecom_customer_churn_cleaned 
RENAME COLUMN SeniorCitizen TO senior_citizen, 
RENAME COLUMN Partner TO has_partner,
RENAME COLUMN Dependents TO dependents,
RENAME COLUMN PhoneService TO has_phone_service, 
RENAME COLUMN MultipleLines TO multiple_lines, 
RENAME COLUMN InternetService TO internet_service, 
RENAME COLUMN OnlineSecurity TO has_online_security, 
RENAME COLUMN OnlineBackup TO has_online_backup, 
RENAME COLUMN DeviceProtection TO has_device_protection, 
RENAME COLUMN TechSupport TO has_tech_support, 
RENAME COLUMN StreamingTV TO has_streaming_tv, 
RENAME COLUMN StreamingMovies TO has_streaming_movies, 
RENAME COLUMN Contract TO contract_type, 
RENAME COLUMN PaperlessBilling TO has_paperless_billing, 
RENAME COLUMN PaymentMethod TO payment_method, 
RENAME COLUMN MonthlyCharges TO monthly_charge, 
RENAME COLUMN TotalCharges TO total_charge, 
RENAME COLUMN Churn TO is_churned;

SELECT * FROM telecom_customer_churn_cleaned;

-- Trimming extra spaces around text column data
UPDATE telecom_customer_churn_cleaned 
SET 
gender=TRIM(gender), 
multiple_lines=TRIM(multiple_lines),
internet_service=TRIM(internet_service), 
has_online_security=TRIM(has_online_security), 
has_online_backup=TRIM(has_online_backup), 
has_device_protection=TRIM(has_device_protection), 
has_tech_support=TRIM(has_tech_support), 
has_streaming_tv=TRIM(has_streaming_tv), 
has_streaming_movies=TRIM(has_streaming_movies), 
contract_type=TRIM(contract_type), 
has_paperless_billing=TRIM(has_paperless_billing), 
payment_method=TRIM(payment_method),
is_churned=TRIM(is_churned);
-- Making inconsistent data to consistent data
/* Change the data in 'senior_citizen' column to 'Yes' for 1 and 'No' for 0 */
SET SESSION sql_mode = '';
ALTER TABLE telecom_customer_churn_cleaned MODIFY senior_citizen VARCHAR(255);
SHOW COLUMNS FROM telecom_customer_churn_cleaned;
SELECT senior_citizen,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY senior_citizen;
UPDATE telecom_customer_churn_cleaned SET senior_citizen=CASE WHEN senior_citizen LIKE "1" THEN "Yes" ELSE "No" END;
SELECT senior_citizen,COUNT(*) FROM telecom_customer_churn_cleaned GROUP BY senior_citizen;
-- Changing column name 'tenure' to 'tenure_month'
ALTER TABLE telecom_customer_churn_cleaned RENAME COLUMN tenure TO tenure_month;
-- Changing column name 'monthly_charge' and 'total_charge' by appending currency name.
ALTER TABLE telecom_customer_churn_cleaned 
RENAME COLUMN monthly_charge TO monthly_charge_usd, 
RENAME COLUMN total_charge TO total_charge_usd;

SELECT * FROM telecom_customer_churn_cleaned;
-- Feature Engineering
SELECT tenure_month, is_churned,
CASE 
WHEN tenure_month=1 THEN "New customer" 
WHEN tenure_month>=2 AND tenure_month<=6 THEN "Returning customer" 
WHEN tenure_month>6 AND tenure_month<=24 THEN "Regular customer"
ELSE "Loyal customer" END AS "customer_type"
FROM telecom_customer_churn_cleaned;
-- Creating new column 'customer_type_by_tenure' to categorize customers based on their tenure.
ALTER TABLE telecom_customer_churn_cleaned ADD COLUMN customer_type_by_tenure VARCHAR(255);
UPDATE telecom_customer_churn_cleaned SET customer_type_by_tenure=CASE 
WHEN tenure_month=1 THEN "New customer" 
WHEN tenure_month>=2 AND tenure_month<=6 THEN "Returning customer" 
WHEN tenure_month>6 AND tenure_month<=24 THEN "Regular customer" 
ELSE "Loyal customer" END;

ALTER TABLE telecom_customer_churn_cleaned ADD COLUMN total_addons INT;
UPDATE telecom_customer_churn_cleaned SET total_addons=COALESCE(total_addons,0);
UPDATE telecom_customer_churn_cleaned SET total_addons=total_addons+1 WHERE has_online_security LIKE 'Yes';
UPDATE telecom_customer_churn_cleaned SET total_addons=total_addons+1 WHERE has_online_backup LIKE 'Yes';
UPDATE telecom_customer_churn_cleaned SET total_addons=total_addons+1 WHERE has_device_protection LIKE 'Yes';
UPDATE telecom_customer_churn_cleaned SET total_addons=total_addons+1 WHERE has_tech_support LIKE 'Yes';
UPDATE telecom_customer_churn_cleaned SET total_addons=total_addons+1 WHERE has_streaming_tv LIKE 'Yes';
UPDATE telecom_customer_churn_cleaned SET total_addons=total_addons+1 WHERE has_streaming_movies LIKE 'Yes';
-- Tenure years
ALTER TABLE telecom_customer_churn_cleaned ADD COLUMN tenure_years FLOAT;
UPDATE telecom_customer_churn_cleaned SET tenure_years=TRUNCATE((tenure_month/12),2);
-- Family status
ALTER TABLE telecom_customer_churn_cleaned ADD COLUMN family_status VARCHAR(255);
UPDATE telecom_customer_churn_cleaned SET family_status=
CASE 
WHEN has_partner LIKE "Yes" OR dependents LIKE 'Yes' THEN "Family" 
ELSE "Individual"
END;
-- Data validation after update
SELECT has_partner,COUNT(*) FROM telecom_customer_churn_cleaned WHERE family_status LIKE 'Individual' GROUP BY has_partner;
SELECT dependents,COUNT(*) FROM telecom_customer_churn_cleaned WHERE family_status LIKE 'Individual' GROUP BY dependents;
-- Entertainment
ALTER TABLE telecom_customer_churn_cleaned ADD COLUMN entertainment VARCHAR(100);
UPDATE telecom_customer_churn_cleaned SET entertainment="Yes" WHERE has_streaming_tv LIKE 'Yes';
UPDATE telecom_customer_churn_cleaned SET entertainment="Yes" WHERE has_streaming_movies LIKE 'Yes';
UPDATE telecom_customer_churn_cleaned SET entertainment=COALESCE(entertainment,"No");
SELECT * FROM telecom_customer_churn_cleaned LIMIT 5;
-- Changing positions of columns
ALTER TABLE telecom_customer_churn_cleaned MODIFY COLUMN tenure_years FLOAT AFTER tenure_month;
ALTER TABLE telecom_customer_churn_cleaned MODIFY COLUMN total_addons INT AFTER has_streaming_movies;
SELECT * FROM telecom_customer_churn_cleaned LIMIT 5;
-- Creating table with only churned customers data
CREATE TABLE churned_customers AS SELECT * FROM telecom_customer_churn_cleaned WHERE is_churned LIKE 'Yes';
SELECT is_churned,COUNT(*) FROM churned_customers GROUP BY is_churned;
ALTER TABLE churned_customers RENAME COLUMN monthly_charge_inr TO monthly_charge_usd;
ALTER TABLE churned_customers RENAME COLUMN total_charge_inr TO total_charge_usd;
/* Data validation after data cleaning */
SELECT COUNT(*) FROM telecom_customer_churn_cleaned;   -- 7032 rows
SHOW COLUMNS FROM telecom_customer_churn_cleaned;
SELECT * FROM telecom_customer_churn_cleaned;
SELECT COUNT(*) FROM churned_customers;  -- 1869 rows
SELECT * FROM churned_customers;

-- ANALYSIS ON CLEANED DATASET
-- Maximum monthly charge paid by customers for different internet services
SELECT internet_service,MAX(monthly_charge_usd) 
FROM telecom_customer_churn_cleaned 
WHERE internet_service NOT LIKE 'No' 
GROUP BY internet_service 
ORDER BY MAX(monthly_charge_usd);
/*
DSL	94.8
Fiber optic	118.75
*/

-- Number of churned customers
SELECT COUNT(*) FROM telecom_customer_churn_cleaned WHERE is_churned LIKE 'Yes';  -- 1869 customers churned

-- Number of churned customers in 1 month
SELECT COUNT(*) FROM churned_customers WHERE tenure_month=1;  -- 380 customers

-- Number of churned customers after 6 months
SELECT COUNT(*) FROM churned_customers WHERE tenure_month<=6;  -- 784 customers

-- Number of churned customers by gender
SELECT gender,COUNT(*) FROM churned_customers GROUP BY gender;  -- 930 male, 939 female

-- Number of churned customers by age group
SELECT senior_citizen,COUNT(*) FROM churned_customers GROUP BY senior_citizen;  
/*
476 Senior citizens, 1393 people less than senior citizen's age
*/

-- Number of churned customers by telecom contract type
SELECT contract_type,COUNT(*) FROM churned_customers GROUP BY contract_type;
/*
Month-to-month	1655
Two year	48
One year	166
*/

-- Number of churned customers based on tenure in months
SELECT tenure_month,COUNT(*) FROM churned_customers GROUP BY tenure_month ORDER BY tenure_month; 
/* 
Churning is higher with customers who had tenure of only 1 month 
*/

-- Number of churned customers based on using phone service or not.
SELECT has_phone_service,COUNT(*) FROM churned_customers GROUP BY has_phone_service;  
/* 
1699 customers had phone service, 170 customers had no phone service 
*/

-- Number of churned customers using internet service or not
SELECT internet_service,COUNT(*) FROM churned_customers GROUP BY internet_service;
/*
DSL	459
Fiber optic	1297
No	113
*/

-- Number of churning by family status
SELECT family_status,COUNT(*) FROM churned_customers GROUP BY family_status; 
/*
1123 individuals and 746 family customers churned. Individual users have churned more.
*/

-- Number of churning by tenure type
SELECT customer_type_by_tenure,COUNT(*) FROM churned_customers GROUP BY customer_type_by_tenure ORDER BY COUNT(*) DESC;
/*
Regular customer	547
Loyal customer	538
Returning customer	404
New customer	380
*/

-- Number of churned customers by total addon count.
SELECT total_addons,COUNT(*) FROM churned_customers GROUP BY total_addons;
/*
3	306
4	190
1	442
5	71
6	15
*/

-- Number of churned customers by presence of partner or not
SELECT has_partner,COUNT(*) FROM churned_customers GROUP BY has_partner;
/*
No	1200
Yes	669
*/

-- Number of churned customers by presence of dependents or not
SELECT dependents,COUNT(*) FROM churned_customers GROUP BY dependents;
/*
No	1543
Yes	326
*/

-- Number of churned customers by payment method
SELECT payment_method,COUNT(*) FROM churned_customers GROUP BY payment_method;
/*
Mailed check	308
Electronic check	1071
Bank transfer (automatic)	258
Credit card (automatic)	232
*/

-- Maximum tenure by customers in months
SELECT MAX(tenure_month) FROM telecom_customer_churn_cleaned;  -- 72 months

-- Number of customers who stayed with the telecom for 72 months
SELECT COUNT(*) FROM telecom_customer_churn_cleaned WHERE tenure_month=72;  -- 362 customers

-- Segregate number of churned and active customers whose tenure is 72 months
SELECT is_churned,COUNT(*) FROM telecom_customer_churn_cleaned WHERE tenure_month=72 GROUP BY is_churned;
/*
356 active customers
6 churned customers
*/

-- Churn rate for 72 month tenure
SELECT 
(
SELECT COUNT(*) 
FROM telecom_customer_churn_cleaned 
WHERE 
tenure_month=72 
AND 
is_churned LIKE 'Yes'
)*100/(
SELECT COUNT(*) 
FROM telecom_customer_churn_cleaned 
WHERE tenure_month=72
) 
AS churn_rate_for_72_months_pct;
/* 1.65% churn rate for customers whose tenure is 72 months */

-- Churn rate for every tenure in months
WITH ChurnRateCTE AS (
	SELECT tenure_month,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY tenure_month
)
SELECT *,
(total_churned_customers*100.0/total_customers) AS churn_rate 
FROM ChurnRateCTE 
ORDER BY tenure_month;

-- Churn rate by gender
WITH ChurnRateGroupedGenderCTE AS (
	SELECT gender,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY gender
)
SELECT *,
(total_churned_customers*100.0/total_customers) AS churn_rate 
FROM ChurnRateGroupedGenderCTE;

-- Churn rate by tenure type
WITH ChurnRateTenureTypeCTE AS (
	SELECT customer_type_by_tenure,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY customer_type_by_tenure
)
SELECT *,
(total_churned_customers*100.0/total_customers) 
AS churn_rate_pct 
FROM ChurnRateTenureTypeCTE 
ORDER BY churn_rate_pct DESC;

-- Churn rate based on number of add-on services provided.
WITH ChurnRateAddonCTE AS (
	SELECT total_addons,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY total_addons
)
SELECT *,
(total_churned_customers*100.0/total_customers) 
AS churn_rate_pct 
FROM ChurnRateAddonCTE ORDER BY total_addons;

-- Churn rate by different internet service types.
WITH ChurnRateInternetTypeCTE AS (
	SELECT internet_service,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY internet_service
)
SELECT *,
(total_churned_customers*100.0/total_customers) 
AS churn_rate_pct 
FROM ChurnRateInternetTypeCTE 
ORDER BY churn_rate_pct DESC;

-- Churn rate by family status
WITH ChurnRateFamilyStatusCTE AS (
	SELECT family_status,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY family_status
)
SELECT *,
(total_churned_customers*100.0/total_customers) 
AS churn_rate_pct 
FROM ChurnRateFamilyStatusCTE 
ORDER BY churn_rate_pct DESC;

-- Churn rate by customers with presence or absence of online security
WITH ChurnRateOnlineSecurityCTE AS (
	SELECT has_online_security,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY has_online_security
)
SELECT *,
(total_churned_customers*100.0/total_customers) 
AS churn_rate_pct 
FROM ChurnRateOnlineSecurityCTE 
ORDER BY churn_rate_pct DESC;   -- Customers with no online security churns more.

-- Churn rate by payment method
WITH ChurnRatePaymentMethodCTE AS (
	SELECT payment_method,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY payment_method
)
SELECT *,
(total_churned_customers*100.0/total_customers) 
AS churn_rate_pct 
FROM ChurnRatePaymentMethodCTE 
ORDER BY churn_rate_pct DESC;   -- Customer with automatic payment methods churn less.

-- Retention rate by customers based on customer tenure type.
WITH RetentionRateCustomerTenureTypeCTE AS (
	SELECT customer_type_by_tenure,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'No' 
        THEN 1 END) 
    AS total_retention_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY customer_type_by_tenure
)
SELECT *,
(total_retention_customers*100.0/total_customers) 
AS retention_rate_pct 
FROM RetentionRateCustomerTenureTypeCTE 
ORDER BY retention_rate_pct DESC;   -- Loyal customers have higher retention rate of 85.96%

-- Churn rate by usage of entertainment services.
WITH ChurnRateEntertainmentCTE AS (
	SELECT entertainment,
    COUNT(*) AS total_customers,
    COUNT(CASE 
		WHEN is_churned LIKE 'Yes' 
        THEN 1 END) 
    AS total_churned_customers 
    FROM telecom_customer_churn_cleaned 
    GROUP BY entertainment
)
SELECT *,
(total_churned_customers*100.0/total_customers) 
AS churn_rate_pct 
FROM ChurnRateEntertainmentCTE 
ORDER BY churn_rate_pct DESC;  -- Customer with entertainment services have higher churn rate of 30%.



-- Top Valuable Churned customers lost in each contract type 
WITH TopCustomerByContractType AS (
	SELECT *, DENSE_RANK() OVER(PARTITION BY contract_type ORDER BY total_charge_usd DESC) AS denseRank FROM churned_customers
),
TopChurnedContractTypeRowNumCTE AS (
	SELECT gender,senior_citizen,tenure_month,total_addons,contract_type,total_charge_usd,denseRank,ROW_NUMBER() OVER(PARTITION BY contract_type ORDER BY total_charge_usd DESC) AS rowNum FROM TopCustomerByContractType
)
SELECT 
gender,senior_citizen,tenure_month,total_addons,contract_type,total_charge_usd,rowNum 
FROM TopChurnedContractTypeRowNumCTE 
WHERE rowNum=1;
/*
Male	Yes	71	4	Month-to-month	7548.1	1
Male	No	72	6	One year	8684.8	1
Male	No	68	6	Two year	7856	1
*/



SHOW COLUMNS FROM telecom_customer_churn_cleaned;
SELECT * FROM telecom_customer_churn_cleaned;
SELECT * FROM churned_customers;