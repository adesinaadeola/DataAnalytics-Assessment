SELECT
    us.id AS customer_id, 
    CONCAT(us.first_name,' ',us.last_name) AS name, 
    us.tenure_months,
    us.total_transactions,
    ROUND(us.total_transactions/us.tenure_months * 12 * us.avg_profit_per_transaction, 2) AS estimated_clv
FROM
	(SELECT 
		u.id,
		u.first_name,
		u.last_name,
		TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months, 
		COUNT(s.id) AS total_transactions,
        AVG(s.confirmed_amount /100 * 0.001) AS avg_profit_per_transaction -- the amount was converted to naira from kobo
	FROM 
       users_customuser u 
    JOIN 
	   savings_savingsaccount s ON u.id=s.owner_id 
    WHERE
        s.confirmed_amount IS NOT NULL
    GROUP BY 
        u.id) AS us
ORDER BY 
    estimated_clv DESC;

