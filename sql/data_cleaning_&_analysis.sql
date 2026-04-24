--cek data
SELECT *
FROM customer_churn
LIMIT 10;

-- cek struktur data 
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customer_churn';

--ubah semua nama kolom jadi lowercase
CREATE TABLE customer_churn_clean AS
SELECT
    "Age" AS age,
    "Gender" AS gender,
    "Country" AS country,
    "City" AS city,
    "Membership_Years" AS membership_years,
    "Login_Frequency" AS login_frequency,
    "Session_Duration_Avg" AS session_duration_avg,
    "Pages_Per_Session" AS pages_per_session,
    "Cart_Abandonment_Rate" AS cart_abandonment_rate,
    "Wishlist_Items" AS wishlist_items,
    "Total_Purchases" AS total_purchases,
    "Average_Order_Value" AS average_order_value,
    "Days_Since_Last_Purchase" AS days_since_last_purchase,
    "Discount_Usage_Rate" AS discount_usage_rate,
    "Returns_Rate" AS returns_rate,
    "Email_Open_Rate" AS email_open_rate,
    "Customer_Service_Calls" AS customer_service_calls,
    "Product_Reviews_Written" AS product_reviews_written,
    "Social_Media_Engagement_Score" AS social_media_engagement_score,
    "Mobile_App_Usage" AS mobile_app_usage,
    "Payment_Method_Diversity" AS payment_method_diversity,
    "Lifetime_Value" AS lifetime_value,
    "Credit_Balance" AS credit_balance,
    "Churned" AS churned,
    "Signup_Quarter" AS signup_quarter
FROM customer_churn;

--cek kolom age
SELECT *
FROM customer_churn
WHERE "Age" < 15 OR "Age" > 80;

--cleaning kolom age
CREATE TABLE customer_churn_clean_v2 AS
SELECT *
FROM customer_churn_clean
WHERE age BETWEEN 15 AND 80;

-- cek total purcahses
SELECT total_purchases
FROM customer_churn_clean
ORDER BY total_purchases DESC
LIMIT 20;

--cek average order value
SELECT average_order_value
FROM customer_churn_clean
ORDER BY average_order_value DESC
LIMIT 20;

--cleaning aov dengan filter nilai yang masuk akal
CREATE TABLE customer_churn_final AS
SELECT *
FROM customer_churn_clean
WHERE age BETWEEN 15 AND 80
  AND average_order_value < 1000;

--handling missing value
SELECT
    COUNT(*) FILTER (WHERE age IS NULL) AS age_null,
    COUNT(*) FILTER (WHERE session_duration_avg IS NULL) AS session_null
FROM customer_churn_final;

--handling missing values session duration avg jadi insight
SELECT *,
CASE 
    WHEN session_duration_avg IS NULL THEN 'No Activity'
    ELSE 'Active'
END AS session_status
FROM customer_churn_final;

--cek distribusi churn
SELECT churned, COUNT(*)
FROM customer_churn_final
GROUP BY churned;

--Analisis
---1. apakah aktivitas user berpengaruh ke churn?
SELECT 
CASE 
    WHEN session_duration_avg IS NULL THEN 'No Activity'
    ELSE 'Active'
END AS session_status,
COUNT(*) AS total_user,
ROUND(AVG(churned)*100,2) AS churn_rate
FROM customer_churn_final
GROUP BY session_status;

--Behaviour vs churn 
SELECT 
ROUND(login_frequency) AS login_group,
ROUND(AVG(churned)*100,2) AS churn_rate
FROM customer_churn_final
GROUP BY login_group
ORDER BY login_group;

-- binning 
SELECT 
CASE 
    WHEN login_frequency = 0 THEN '0'
    WHEN login_frequency BETWEEN 1 AND 5 THEN '1-5'
    WHEN login_frequency BETWEEN 6 AND 10 THEN '6-10'
    WHEN login_frequency BETWEEN 11 AND 20 THEN '11-20'
    ELSE '20+'
END AS login_group,
COUNT(*) AS total_user,
ROUND(AVG(churned)*100,2) AS churn_rate
FROM customer_churn_final
GROUP BY login_group
ORDER BY login_group;

--value vs churn 
SELECT 
ROUND(average_order_value::numeric, -1) AS aov_group,
ROUND(AVG(churned)*100,2) AS churn_rate
FROM customer_churn_final
GROUP BY aov_group
ORDER BY aov_group;

--binning
SELECT 
CASE 
    WHEN average_order_value < 100 THEN '<100'
    WHEN average_order_value BETWEEN 100 AND 200 THEN '100-200'
    WHEN average_order_value BETWEEN 200 AND 300 THEN '200-300'
    ELSE '300+'
END AS aov_group,
COUNT(*) AS total_user,
ROUND(AVG(churned)*100,2) AS churn_rate
FROM customer_churn_final
GROUP BY aov_group
ORDER BY aov_group;

SELECT * FROM customer_churn_final;