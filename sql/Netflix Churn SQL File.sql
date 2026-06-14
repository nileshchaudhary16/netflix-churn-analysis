# Q-1 Overall churn rate

SELECT COUNT(*) AS total_users,
SUM(churned_flag) AS Churned_users,
ROUND(SUM(churned_flag) * 100.0 / COUNT(*),2) as Churn_rate_pct
FROM netflix_churn

# Q-2 Churn by subscription type

SELECT subscription_type, COUNT(*) AS total_users,
SUM(churned_flag) AS churned_users,
ROUND(SUM(churned_flag) * 100.0 / COUNT(*),2) AS Churned_rate_pct
FROM netflix_churn
GROUP BY subscription_type
ORDER BY churned_rate_pct DESC;

# Q-3 Churn by activity level

SELECT
	CASE 
		WHEN days_since_last_login <= 15 THEN 'Active'
        WHEN days_since_last_login <= 30 THEN 'Moderate'
        ELSE 'Inactive'
	END AS activity_level,
    COUNT(*) AS total_users,
    SUM(churned_flag) AS churned_users,
    ROUND(SUM(churned_flag) * 100.0 / COUNT(*), 2) as churn_rate_pct
FROM netflix_churn
GROUP BY activity_level
ORDER BY churn_rate_pct DESC;

# Q-4 Revenue at risk

SELECT 
   ROUND(SUM(monthly_fee),2) as total_monthly_revenue,
   ROUND(SUM( CASE WHEN churned_flag = 1 THEN monthly_fee ELSE 0 END), 2) AS revenue_at_risk,
   ROUND(SUM( CASE WHEN churned_flag = 1 THEN monthly_fee ELSE 0 END) * 100.0 / SUM(monthly_fee), 2) as revenue_risk_pct
FROM netflix_churn
ORDER BY revenue_risk_pct DESC;

# Q-5 High risk users (low watch time + inactive)

SELECT 
    COUNT(*) AS high_risk_users,
    SUM(churned_flag) AS churned_count,
    ROUND(SUM(churned_flag) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(SUM(CASE WHEN churned_flag = 1 THEN monthly_fee ELSE 0 END), 2) AS revenue_at_risk
FROM netflix_churn
WHERE avg_watch_time_minutes < (SELECT AVG(avg_watch_time_minutes) FROM netflix_churn)
AND days_since_last_login > (SELECT AVG(days_since_last_login) FROM netflix_churn);

# Q-6 Churn by Engagement Level

SELECT 
    CASE 
        WHEN avg_watch_time_minutes <= 200 THEN 'Low'
        WHEN avg_watch_time_minutes <= 400 THEN 'Medium'
        ELSE 'High'
    END AS engagement_level,
    COUNT(*) AS total_users,
    SUM(churned_flag) AS churned_users,
    ROUND(SUM(churned_flag) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM netflix_churn
GROUP BY engagement_level
ORDER BY churn_rate_pct DESC;

# Q-7 Premium high risk users

SELECT 
    COUNT(*) AS premium_high_risk_users,
    SUM(churned_flag) AS churned_count,
    ROUND(SUM(churned_flag) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(SUM(CASE WHEN churned_flag = 1 THEN monthly_fee ELSE 0 END), 2) AS revenue_at_risk
FROM netflix_churn
WHERE subscription_type = 'Premium'
AND avg_watch_time_minutes < (SELECT AVG(avg_watch_time_minutes) FROM netflix_churn)
AND days_since_last_login > (SELECT AVG(days_since_last_login) FROM netflix_churn);

# Q-8 New customer churn (tenure based)

SELECT 
    CASE 
        WHEN account_age_months <= 6 THEN 'New (0-6m)'
        WHEN account_age_months <= 12 THEN 'Early (6-12m)'
        WHEN account_age_months <= 24 THEN 'Established (1-2yr)'
        ELSE 'Loyal (2yr+)'
    END AS customer_tenure,
    COUNT(*) AS total_users,
    SUM(churned_flag) AS churned_users,
    ROUND(SUM(churned_flag) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM netflix_churn
GROUP BY customer_tenure
ORDER BY churn_rate_pct DESC;

# Q-9 Subscription + engagement cross analysis

SELECT 
    subscription_type,
    CASE 
        WHEN avg_watch_time_minutes <= 200 THEN 'Low'
        WHEN avg_watch_time_minutes <= 400 THEN 'Medium'
        ELSE 'High'
    END AS engagement_level,
    COUNT(*) AS total_users,
    SUM(churned_flag) AS churned_users,
    ROUND(SUM(churned_flag) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM netflix_churn
GROUP BY subscription_type, engagement_level
ORDER BY churn_rate_pct DESC;

# Q-10 Binge watchers vs non binge watchers

SELECT 
    CASE 
        WHEN binge_watch_sessions > (SELECT AVG(binge_watch_sessions) FROM netflix_churn) THEN 'Binge Watcher'
        ELSE 'Non Binge Watcher'
    END AS user_type,
    COUNT(*) AS total_users,
    SUM(churned_flag) AS churned_users,
    ROUND(SUM(churned_flag) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM netflix_churn
GROUP BY user_type
ORDER BY churn_rate_pct DESC;