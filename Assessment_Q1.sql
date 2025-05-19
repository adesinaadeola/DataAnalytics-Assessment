SELECT 
    us.id AS owner_id, 
    CONCAT(us.first_name, ' ', us.last_name) AS name,

    COUNT(DISTINCT 
        CASE 
            WHEN pp.is_regular_savings = 1 THEN pp.id 
        END
    ) AS savings_count, 

    COUNT(DISTINCT 
        CASE 
            WHEN pp.is_a_fund = 1 THEN pp.id 
        END
    ) AS investment_count, 

    SUM(ss.confirmed_amount/100) AS total_deposits -- converted the amount from kobo to naira

FROM 
    users_customuser us

JOIN 
    savings_savingsaccount ss 
    ON us.id = ss.owner_id

JOIN 
    plans_plan pp 
    ON pp.id = ss.plan_id 
    AND us.id = pp.owner_id 

WHERE 
    us.is_active = 1 

GROUP BY 
    us.id, name

HAVING 
    savings_count >= 1 
    AND investment_count >= 1

ORDER BY 
    total_deposits;
