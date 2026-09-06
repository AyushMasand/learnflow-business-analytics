{{config(materialized = 'table')}}

with path_viewed as (
select 
    user_id,
    MIN(event_timestamp) as learning_path_viewed_time
from {{ref('fact_events')}}
where event_name = 'learning_path_viewed'
group by user_id),
learning_started as (
select 
    p.user_id,
    MIN(r.event_timestamp) as lesson_started_time
from path_viewed p 
join {{ref('fact_events')}} r 
on r.user_id = p.user_id and r.event_name = 'lesson_started' and r.event_timestamp > p.learning_path_viewed_time
group by p.user_id),
learning_completed as (
select
    s.user_id,
    MIN(r.event_timestamp) as lesson_completed_time
from learning_started s 
join {{ref('fact_events')}} r 
on r.user_id = s.user_id and r.event_name = 'lesson_completed' and r.event_timestamp > s.lesson_started_time
group by s.user_id),
final as (
select 
    1 as priority,
    'learning_path_viewed' as event_name,
    count(user_id) as users_count
from path_viewed
UNION ALL
select 
    2,
    'lesson_started',
    count(user_id)
from learning_started
UNION ALL
select 
    3,
    'lesson_completed',
    count(user_id)
from learning_completed)

select 
    priority,
    event_name,
    users_count
from final