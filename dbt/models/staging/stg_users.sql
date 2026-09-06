
{{config(materialized = 'view')}}

with ranked as (
    select 
        *,
        row_number() over(partition by user_id order by signup_date) as rn
    from {{source('raw','users')}}
)

select
    CAST(user_id AS VARCHAR(20)) AS user_id,
    CAST(signup_date AS DATETIME) AS signup_date,
    CAST(country AS VARCHAR(50)) AS country,
    CAST(age_group AS VARCHAR(20)) AS age_group,
    CAST(acquisition_channel AS VARCHAR(50)) AS acquisition_channel,
    CAST(device_type AS VARCHAR(30)) AS device_type,
    CAST(learning_goal AS VARCHAR(100)) AS learning_goal,
    CAST(skill_level AS VARCHAR(30)) AS skill_level
from ranked
where rn = 1