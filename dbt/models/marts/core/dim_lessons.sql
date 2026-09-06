{{ config(materialized='table') }}

SELECT
    lesson_id,
    course_id,
    lesson_number,
    lesson_title,
    duration_minutes
FROM {{ ref('stg_lessons') }}