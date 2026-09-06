{{ config(materialized='table') }}

SELECT
    event_id,
    user_id,
    session_id,
    event_timestamp,
    CAST(event_timestamp AS DATE) AS event_date,
    DATETRUNC(MONTH,event_timestamp) AS event_month,
    event_name,
    course_id,
    lesson_id,
    device_type,
    event_value
FROM {{ ref('stg_events') }}