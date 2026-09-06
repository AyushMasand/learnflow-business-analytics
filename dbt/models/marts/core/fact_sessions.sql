{{ config(materialized='table') }}

SELECT
    session_id,
    user_id,
    session_start,
    session_end,
    CAST(session_start AS DATE) AS session_date,
    DATETRUNC(MONTH,session_start) AS session_month,
    device_type,
    DATEDIFF(MINUTE,session_start,session_end) AS session_duration_minutes
FROM {{ ref('stg_sessions') }}