{{ config(materialized='table') }}

SELECT
    course_id,
    course_name,
    category,
    difficulty,
    estimated_hours,
    is_premium,
    CASE
        WHEN is_premium = 1 THEN 'Premium'
        ELSE 'Free'
    END AS course_type
FROM {{ ref('stg_courses') }}