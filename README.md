# DataAnalytics-Assessment

**This repository contains my solutions to the SQL Proficiency Assessment.**

## Assessment_Q1.sql

**Objective**: 

Help business identify customers with at least one funded savings plan and one funded investment plan. 

**Approach**: 

To find customers who have at least one savings and one investment plan, I joined the `users_customuser`, `savings_savingsaccount`, and `plans_plan` table using an inner join. This helps filter for users who have records in all the three tables.  
The `users_customuser` and `savings_savingsaccount` tables are joined using `users_customuser.id` (a primary key) and `savings_savingsaccount.owner_id`. The `plans_plan` table is joined  via `plans_plan.id = savings_savingsaccount.plan_id` to  ensure the query returns the correct plan associated with each user. Although the customers' status was not explicitly specified, I added a condition to filter for only active customers. 

Because the `name` column in `users_customuser` table is null, I concatenated the first and last names of the users to obtain their full names. I counted the unique savings and investment plans associated with each customer. To ensure only confirmed payments were included, I used the `confirmed_amount` column in `savings_savingsaccount` to calculate the total deposit. 

After grouping by `owner_id` and `name`, I used the `HAVING` keyword to filter for users who had at least one regular savings and one investment plan (`is_regular_savings = 1` and `is_a_fund = 1`). 

**Challenges:**
The main challenge I encountered in this assessment was converting MySQL syntax in the provided SQL file to Oracle SQL syntax. I initially tried to convert it because I am more comfortable with Oracle SQL and that's the database installed on my local computer. To resolve this, I downloaded MySQL and ran the SQL file (`adashi_assessment.sql`) as provided. I also mistakenly used some Oracle-specific syntax, which caused errors. I was able to identify and fix these quickly, and I took time to learn some nuances of MYSQL.


## Assessment_Q2.sql

**Goal:**
Calculate the average number of transactions per customer per month and categorize them by frequency (high, medium, and low) 

**Approach:**
To avoid redundancy, I used Common Table Expression (CTE) to calculate the average number of transactions each customer made per month (`transaction_detail`) and to derive the transaction frequency. `TIMESTAMPDIFF` was used to compute the difference in months between the earliest and latest `transaction_date` for each customer, including those with less than one month. 
The frequency categories were based on the values in the `transaction_detail` CTE. To ensure correct categorization, I rounded the `transactions_per_month` column (obtained from `transaction_detail` CTE) to the nearest whole number. 
Using a `GROUP BY`, I summarized the `frequency_category` to get the total number of customers in each category and their average transactions per month. 
...

**Challenges:**
I had difficulty deciding on the best-performing query with optimal readability. To overcome the challenge, I wrote two versions of the query: One using a CTE and one without a CTE. I chose the CTE version because it was clearer and helped avoid repetitive calculations, especially when deriving average transactions and frequency categories. I also compared the execution time in seconds for both versions. 

## Assessment_Q3.sql

**Goal:**
Provide the Ops team with all active accounts (savings or investments) that have no transactions in the past year (365 days).

**Approach:**

I selected the plan ID and owner ID from `plans_plan` and `savings_savingsaccount` tables respectively, and used a `CASE` statement to categorize each plan as savings (`is_regular_savings`=1) or investment (`is_a_fund`=1). 
To ensure all plans and their corresponding owner IDs were captured (even if there are no transactions on `savings_savingsaccount`) I used a left join with `plans_plan` on the left side. 
**Note: The left join results in null values in `last_transaction_date` and `inactivity_days` columns when there are no corresponding rows in `savings_savingsaccount`.**
I included `s.confirmed_amount > 0` to filter for inflow transactions and
`s.transaction_date IS NULL` to include accounts without any transactions. I also filtered for plans that are neither deleted nor archived.

`TIMESTAMPDIFF` was used to calculate the number of days between the last transaction date and the current date. The query was grouped by plan ID, owner ID, and account TYPE (savings, investment, or others). 
**Note: The archived records on `plans_plan` table was treated as inactive plan.**
After grouping, I filtered for records with more than 365 days of inactivity.

**Challenges:**
I struggled with figuring out the best way to retain active accounts without losing some records on `plans_plan` that had no transactions and determining if archived records should be treated as active or inactive records. After much consideration, I opted for a left join that captures every row in `plans_plan` and used `s.confirmed_amount > 0` to ensure accounts with inflow transactions are included. I also included a `WHERE` clause to filter out deleted and archived plans.


I had a challenge figuring out the best way to retain active accounts without losing some records on `plans_plan` that had no transactions in `savings_savingsaccount`. After much consideration, I opted for a left join that captures every row in `plans_plan` and used `s.confirmed_amount > 0` to ensure only active accounts were included. 

## Assessment_Q4.sql

**Goal:**
Estimate Customer Lifetime Value (CLV) based on account tenure and transaction volume.

**Approach:**
The query includes a subquery that calculates tenure in months, total transactions, and average confirmed amount. The `tenure_months` was calculated using `TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())` which is the difference between the join date and the current date. The `total_transactions` was derived using `COUNT(savings_savingsaccount.id)`. The `avg_profit_per_transaction` was computed using AVG(s.confirmed_amount * 0.001) since 0.001 represents 0.1%. 
The outer query retrieves the customer ID, full name (concatenated from first and last names), tenure (in months), total transactions, and estimated CLV which is calculated as: `ROUND(us.total_transactions/us.tenure_months * 12 * us.avg_profit_per_transaction, 2)` (`us` is the alias for the subquery.) 
**Note:** The subquery was added for clarity and efficiency. The `name` column in `users_customuser` could not be used as it contains null values.

**Challenges:** 
I spent time understanding how to correctly calculate `avg_profit_per_transaction`. To do this accurately, I examined all the relevant columns in `savings_savingsaccount`. 

**Note: All amounts are converted from kobo to naira**