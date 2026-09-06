{{config(materialized = 'view')}}

select 
    CAST(lesson_id AS VARCHAR(20)) AS lesson_id,
    CAST(course_id AS VARCHAR(20)) AS course_id,
    CAST(lesson_number AS INT) AS lesson_number,
    CAST(lesson_title AS VARCHAR(200)) AS lesson_title,
    CAST(duration_minutes AS INT) AS duration_minutes
from {{source('raw','lessons')}}
where duration_minutes > 0 and lesson_number >= 0