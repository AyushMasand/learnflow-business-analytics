{{config(marketing = 'view')}}

with ranked as (
    select 
        *,
        row_number() over(partition by event_id,user_id order by event_timestamp) as rn
    from {{source('raw','events')}}
    where event_timestamp is not null
)

select 
    CAST(event_id AS VARCHAR(30)) AS event_id,
    CAST(user_id AS VARCHAR(20)) AS user_id,
    CAST(session_id AS VARCHAR(30)) AS session_id,
    CAST(event_timestamp AS DATETIME) AS event_timestamp,
    CAST(event_name AS VARCHAR(100)) AS event_name,
    CAST(course_id AS VARCHAR(20)) AS course_id,
    CAST(lesson_id AS VARCHAR(20)) AS lesson_id,
    CAST(device_type AS VARCHAR(30)) AS device_type,
    CAST(event_value AS DECIMAL(18,2)) AS event_value
from ranked
where rn = 1