{{config(materialized = 'table')}}

with user_sessions_details as (
    select 
        user_id,
        count(DISTINCT session_id) as session_count,
        sum(session_duration_minutes) as total_session_minutes,
        avg(session_duration_minutes) as avg_session_minutes
    from {{ref('fact_sessions')}}
    group by user_id
)

select 
    u.user_id,
    f.event_month,
    MAX(u.signup_month) AS signup_month,
    MAX(u.country) AS country,
    MAX(u.age_group) AS age_group,
    MAX(u.acquisition_channel) AS acquisition_channel,
    MAX(u.device_type) AS device_type,
    MAX(u.skill_level) AS skill_level,
    COUNT(DISTINCT f.event_id) as event_count,
    COUNT(DISTINCT CASE
                        WHEN f.event_name = 'lesson_completed' THEN f.lesson_id
            END) as lessons_completed,
    COUNT(DISTINCT CASE
                        WHEN f.event_name = 'quiz_completed' THEN f.lesson_id
            END) as quizzes_completed,
    COUNT(DISTINCT CASE
                        WHEN f.event_name = 'exercise_completed' THEN f.lesson_id
            END) as exercises_completed,
    MAX(s.session_count) AS total_sessions,
    MAX(s.total_session_minutes) AS total_session_duration_minutes,
    MAX(s.avg_session_minutes) as avg_session_duration_minutes,
    CAST(COUNT(DISTINCT f.event_id) * 1.0/MAX(s.session_count) AS decimal(10,2)) as events_per_session
from {{ref('dim_users')}} u
INNER JOIN {{ref('fact_events')}} f
on f.user_id = u.user_id
INNER JOIN user_sessions_details s 
on s.user_id = u.user_id
group by u.user_id,f.event_month