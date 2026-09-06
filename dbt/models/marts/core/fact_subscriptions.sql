{{ config(materialized='table') }}

SELECT
    subscription_id,
    user_id,
    [plan],
    start_date,
    end_date,
    monthly_price,
    status,
    CAST(start_date AS DATE) AS subscription_start_date,
    DATETRUNC(month,start_date) AS subscription_start_month,
    CASE
        WHEN end_date IS NOT NULL THEN DATEDIFF(DAY, start_date, end_date)
        ELSE NULL
    END AS subscription_duration_days
FROM {{ ref('stg_subscriptions') }}