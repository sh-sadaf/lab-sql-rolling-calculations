
#1. Get number of monthly active customers.
use sakila;
CREATE OR REPLACE VIEW user_activity AS
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%m') AS activity_month,
        DATE_FORMAT(rental_date, '%Y') AS activity_year
    FROM
        rental;
SELECT 
    *
FROM
    user_activity;


CREATE OR REPLACE VIEW monthly_active_users AS
    SELECT 
        COUNT(customer_id) AS active_users,
        DATE_FORMAT(rental_date, '%m') AS activity_month,
        DATE_FORMAT(rental_date, '%Y') AS activity_year
    FROM
        rental
    GROUP BY activity_year , activity_month
    ORDER BY activity_year , activity_month;

SELECT 
    *
FROM
    monthly_active_users;

# 2. Active users in the previous month.
select activity_year, activity_month, active_users,
lag(active_users) over (partition by activity_year order by activity_month) as last_month_user from monthly_active_users;

# 3. Percentage change in the number of active customers.
create or replace view percentage_change_in_no_of_users as
with cte_view as(
select activity_year, activity_month, active_users,
lag(active_users) over (partition by activity_year order by activity_month) as last_month_user 
from monthly_active_users)
select activity_year, activity_month, active_users, last_month_user,
round(100*(last_month_user - active_users)/active_users,2) as percentaage_difference
from cte_view;

SELECT 
    *
FROM
    percentage_change_in_no_of_users;

CREATE OR REPLACE VIEW distinct_users AS
    SELECT DISTINCT
        customer_id AS active_id, activity_year, activity_month
    FROM
        sakila.user_activity
    ORDER BY activity_year , activity_month , account_id;

SELECT 
    *
FROM
    distinct_users;

CREATE OR REPLACE VIEW retained_users AS
    SELECT 
        d1.active_id, d1.activity_year, d1.activity_month
    FROM
        distinct_users d1
            JOIN
        distinct_users d2 ON d1.activity_year = d2.activity_year
            AND d1.activity_month = d2.activity_month + 1
            AND d1.active_id = d2.active_id
    ORDER BY d1.active_id , d1.activity_year , d1.activity_month;

SELECT 
    *
FROM
    retained_users;

CREATE OR REPLACE VIEW total_retainted_users AS
    SELECT 
        activity_year,
        activity_month,
        COUNT(active_id) AS retained_users
    FROM
        retained_users
    GROUP BY activity_year , activity_month;

SELECT 
    *
FROM
    total_retainted_users;

create or replace view retained_users_monthly as 
select *,
lag(retained_users) over() as previous_month_users
from total_retainted_users;

SELECT 
    *
FROM
    retained_users_monthly;

