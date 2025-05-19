SELECT 
   p.id AS plan_id, 
   p.owner_id, 
   CASE 
	  WHEN is_regular_savings=1 THEN 'Savings' 
      WHEN is_a_fund=1 THEN 'Investment' 
      ELSE 'Others' 
   END AS type, 
   MAX(s.transaction_date) AS last_transaction_date,
   TIMESTAMPDIFF(DAY, MAX(s.transaction_date), CURDATE()) AS inactivity_days -- obtain the number of days between last transaction date and current date
FROM 
    plans_plan p 
LEFT JOIN 
    savings_savingsaccount s 
    ON p.id=s.plan_id 
    AND s.owner_id=p.owner_id 
    AND s.confirmed_amount > 0 -- confirmed amount for inflow transaction
WHERE
   (p.is_regular_savings = 1 OR p.is_a_fund = 1) -- ensure the plan is either savings or investment
   AND p.is_deleted = 0          -- for active plans
   AND p.is_archived = 0     -- Non-archived plans
GROUP BY
	 p.id, p.owner_id, p.is_regular_savings, p.is_a_fund 
HAVING
     MAX(s.transaction_date) IS NULL     
     OR TIMESTAMPDIFF(DAY, MAX(s.transaction_date), CURDATE()) > 365; -- ensures both null and transaction greater than 365 are included
