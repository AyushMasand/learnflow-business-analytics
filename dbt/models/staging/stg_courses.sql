
{{ config(materialized='view') }}

select
    CAST(course_id AS VARCHAR(20)) AS course_id,
    CAST(course_name AS VARCHAR(200)) AS course_name,
    CAST(category AS VARCHAR(100)) AS category,
    CAST(difficulty AS VARCHAR(30)) AS difficulty,
    CAST(estimated_hours AS INT) AS estimated_hours,
    CAST(is_premium AS BIT) AS is_premium
from {{ source('raw', 'courses') }}
where estimated_hours > 0
