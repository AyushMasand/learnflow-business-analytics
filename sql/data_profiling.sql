-- DATA PROFILING


------------------------------------------------------
---------------USERS TABLE----------------------------
------------------------------------------------------

-- 1. CHECKING IF THERE IS NULL OR NOT

SELECT 
	*
FROM raw.users
where user_id is null

-- NO NULL FOUND

-- 2. RECORD COUNTING

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(*) - COUNT(DISTINCT user_id) AS diff
FROM raw.users;

-- 50008 total rows , 50000 unique and 8 diff

-- 3. CHECKING IF SIGNUP DATE IS NULL OR NOT

SELECT 
	*
FROM raw.users
where signup_date is null

-- NO NULL FOUND

-- 4. CHECKING IF THERE IS DUPLICATE RECORD OR NOT

SELECT 
	user_id,
	count(*) as users_count
FROM raw.users
group by user_id 
having count(*) > 1

-- some records have duplicates

-- INSPECTING A SINGLE USER HAVING DUPLICATE RECORD

SELECT *
FROM raw.users
WHERE user_id = (
    SELECT TOP 1 user_id
    FROM raw.users
    GROUP BY user_id
    HAVING COUNT(*) > 1
);

-- duplicate found

------------------------------------------------------
---------------COURSES TABLE--------------------------
------------------------------------------------------

-- 1. CHECKING IF COURSE ID IS NOT NULL

SELECT 
	*
FROM raw.courses
where course_id is null

-- no null found

-- 2. CHECKING IF null IN premium column

SELECT 
	*
FROM raw.courses
where is_premium is null

-- no null found

-- 3. RECORD COUNTING

SELECT 
	COUNT(*) AS total_records
FROM raw.courses

-- 80 records found

-- 4. CHECKING IF THERE IS DUPLICATE RECORD OR NOT

SELECT 
	course_id,
	count(*) as course_count
FROM raw.courses
group by course_id 
having count(*) > 1

-- no duplicate record

------------------------------------------------------
---------------LESSONS TABLE--------------------------
------------------------------------------------------

-- 1. CHECKING IF LESSON ID IS NOT NULL

SELECT 
	*
FROM raw.lessons
where lesson_id is null

-- no lesson found

-- 2. RECORD COUNTING


SELECT 
	COUNT(*) AS total_records
FROM raw.lessons

-- 1523 records found

-- 3. CHECKING IF COURSE ID IS NOT NULL

select 
	*
from raw.lessons
where course_id is null

-- no null found

-- 4. CHECKING IF THERE IS DUPLICATE RECORD OR NOT

SELECT 
	lesson_id,
	count(*) as lesson_count
FROM raw.lessons
group by lesson_id
having count(*) > 1

-- no duplicate record

------------------------------------------------------
---------------EVENTS TABLE--------------------------
------------------------------------------------------

-- 1. CHECKING IF NULL IN PK OR FK

select 
	*
from raw.events
where event_id is null or user_id is null or session_id is null or course_id is null or lesson_id is null

--  null found in course_id , lesson_id and event_value but there are events that dont have these id's associated with them like signup,onboarding,goal selected etc.

-- 2. RECORD COUNTING

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_id) AS unique_events,
	count(*) - COUNT(DISTINCT event_id) as diff
FROM raw.events;


-- 1598654 total records and 1595645 unique events and diff is 3009

SELECT
    COUNT(*) AS duplicate_rows
FROM (
    SELECT
        event_id
    FROM raw.events
    GROUP BY event_id
    HAVING COUNT(*) > 1
) d;

-- duplicate rows 3009

-- CHEKING IF THERE ARE DUPLICATES OR NOT

select 
	user_id,
	event_id,
	count(*) as event_count
from raw.events
group by user_id,event_id
having count(*) > 1

-- there are about 3009 records and  this table is extremely slow.

-- INSPECTING A RECORD WITH COUNT GREATER THAN 1 FOR CLARITY

SELECT *
FROM raw.events
WHERE event_id = (
    SELECT TOP 1 event_id
    FROM raw.events
    GROUP BY event_id
    HAVING COUNT(*) > 1
);

-- DUPLICATE RECORD



------------------------------------------------------
---------------MARKETING TABLE------------------------
------------------------------------------------------


-- 1. CHECKING IF THERE ARE NULL VALUES IN IMP COLUMNS

SELECT 
	*
FROM raw.marketing
where campaign_id is null or date is null

-- no null records

-- 2. RECORD COUNTING

SELECT 
	count(*) as record_count
FROM raw.marketing

-- 1696 record found

-- 3. CHECKING IF THERE ARE DUPLICATES OR NOT

SELECT 
	campaign_id,
	count(*) as record_count
FROM raw.marketing
group by campaign_id
having count(*) > 1

-- no duplicate records


------------------------------------------------------
---------------SESSIONS  TABLE------------------------
------------------------------------------------------


-- 1. CHECKING IF THERE ARE NULL VALUES IN IMP COLUMNS

SELECT 
	*
FROM raw.sessions
where session_id is null or user_id is null or session_start is null or session_end is null

-- no null found

-- 2. RECORD COUNTING

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT session_id) AS unique_sessions,
    COUNT(*) - COUNT(DISTINCT session_id) AS diff
FROM raw.sessions;

-- 309511 total rows ,308904 unique sessions and 607 diff

-- 3. CHECKING IF THERE ARE DUPLICATES OR NOT

SELECT 
	session_id,
	count(*) as session_count
FROM raw.sessions
group by session_id
having count(*) > 1

-- there are about 607 rows

-- INSPECTING ONE DUPLICATE RECORD

SELECT *
FROM raw.sessions
WHERE session_id = (
    SELECT TOP 1 session_id
    FROM raw.sessions
    GROUP BY session_id
    HAVING COUNT(*) > 1
);

-- DUPLICATE RECORD


------------------------------------------------------
---------------SUBSCRIPTION TABLE--------------------
------------------------------------------------------

-- 1. CHECKING IF THERE ARE NULL VALUES IN IMP COLUMNS

SELECT 
	*
FROM raw.subscriptions
where subscription_id is null or user_id is null or start_date is null or status is null

-- no null found

-- 2. RECORD COUNTING

SELECT 
	COUNT(*) AS total_sessions
FROM raw.subscriptions

-- 3752 records found

-- 3. CHECKING IF THERE ARE DUPLICATES OR NOT

SELECT 
	subscription_id,
	count(*) as session_count
FROM raw.subscriptions
group by subscription_id
having count(*) > 1

-- no duplicate records