{{config(materialized = 'table')}}

with course_details as (
select 
    d.course_id,
    d.category as course_category,
    d.difficulty as course_difficulty,
    d.course_type,
    count(f.lesson_id) as total_lessons
from {{ref('dim_courses')}} d 
join {{ref('dim_lessons')}} f 
on f.course_id = d.course_id
group by d.course_id,d.category,d.difficulty,d.course_type)

select 
    c.course_id,
    e.user_id,
    c.course_category,
    c.course_difficulty,
    c.course_type,
    c.total_lessons,
    COUNT(DISTINCT CASE 
        WHEN e.event_name = 'lesson_started' THEN e.lesson_id
    END) as started_lessons,
    COUNT(DISTINCT CASE 
        WHEN e.event_name = 'lesson_completed' THEN e.lesson_id
    END) as completed_lessons,
    CAST(COUNT(DISTINCT CASE 
        WHEN e.event_name = 'lesson_completed' THEN e.lesson_id
    END) * 100.0 / c.total_lessons AS decimal(10,2)) as course_progress_rate,
    MIN(e.event_date) as first_activity_date,
    MAX(e.event_date) as last_activity_date
from course_details c 
join {{ref('fact_events')}} e 
on e.course_id = c.course_id
group by c.course_id,e.user_id,c.course_category,c.course_difficulty,c.course_type,c.total_lessons

