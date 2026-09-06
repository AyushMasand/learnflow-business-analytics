{{config(materialized = 'view')}}

with ranked as (
select 
    *,
    row_number() over(partition by session_id,user_id order by session_start) as rn
from {{source('raw','sessions')}}
)

select
    CAST(session_id AS VARCHAR(30)) AS session_id,
    CAST(user_id AS VARCHAR(20)) AS user_id,
    CAST(session_start AS DATETIME) AS session_start,
    CAST(session_end AS DATETIME) AS session_end,
    CAST(device_type AS VARCHAR(30)) AS device_type
from ranked
where rn = 1 and session_start <= session_end