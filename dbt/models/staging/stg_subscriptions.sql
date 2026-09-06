{{ config(materialized='view') }}

select
    CAST(subscription_id AS VARCHAR(30)) AS subscription_id,
    CAST(user_id AS VARCHAR(20)) AS user_id,
    CAST([plan] AS VARCHAR(50)) AS [plan],
    CAST(start_date AS DATETIME) AS start_date,
    CAST(end_date AS DATETIME) AS end_date,
    CAST(monthly_price AS DECIMAL(10,2)) AS monthly_price,
    CAST(status AS VARCHAR(30)) AS status
from {{ source('raw', 'subscriptions') }}
where end_date is null or start_date <= end_date