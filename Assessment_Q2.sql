WITH transaction_detail AS (
    SELECT 
        uc.id AS customer_id,
        (
            COUNT(ss.id) /
            CASE 
                WHEN TIMESTAMPDIFF(MONTH, MIN(ss.transaction_date), MAX(ss.transaction_date)) < 1 THEN 1  -- returns 1 when the difference is less than 1 
                ELSE TIMESTAMPDIFF(MONTH, MIN(ss.transaction_date), MAX(ss.transaction_date))
            END
        ) AS transactions_per_month
    FROM 
        users_customuser uc
    JOIN 
        savings_savingsaccount ss ON uc.id = ss.owner_id
    GROUP BY 
        uc.id
),
frequency AS (
    SELECT 
        customer_id, 
        transactions_per_month,
        CASE 
            WHEN ROUND(transactions_per_month, 0) <= 2 THEN 'Low Frequency' -- transactions_per_month was rounded to the nearest whole number to ensure all data are captured
            WHEN ROUND(transactions_per_month, 0) <= 9 THEN 'Medium Frequency'
            ELSE 'High Frequency'
        END AS frequency_category
    FROM 
        transaction_detail
)
SELECT  -- the select statement uses the two CTE queries above to retrieve the required data
    frequency_category, 
    COUNT(*) AS customer_count, 
    ROUND(AVG(transactions_per_month), 1) AS avg_transactions_per_month
FROM 
    frequency 
GROUP BY 
    frequency_category;
