/* 
	BUSINESS ANALYSIS 
*/

-- =========================================================
-- USER ACQUISITION 
-- =========================================================


-- =========================================================
-- 1. Acquisition trend over time
-- =========================================================

with monthly_acquisition AS (
    SELECT
        signup_month,
        COUNT(DISTINCT user_id) AS new_users
    FROM dbt.dim_users
    GROUP BY signup_month)
select
    signup_month,
    new_users,
    LAG(new_users) OVER(ORDER BY signup_month) AS previous_month_users,
    CAST((new_users - LAG(new_users) OVER (ORDER BY signup_month)) * 100.0/ NULLIF(LAG(new_users) OVER(ORDER BY signup_month),0) AS DECIMAL(10,2)) AS mom_growth_pct
FROM monthly_acquisition
ORDER BY signup_month;
/* BUSINESS FINDINGS :  
        LearnFlow's monthly user acquisition remained relatively stable from January through July 2026, 
        averaging roughly 7,143 new users per month, with normal month-to-month fluctuations rather than sustained growth or decline. 
*/


-- =========================================================
-- 2. Which acquisition channels contribute the most new users?
-- =========================================================

with users_acq as (
SELECT
    acquisition_channel,
    COUNT(DISTINCT user_id) AS users_acquired
FROM dbt.dim_users
GROUP BY acquisition_channel)

select 
    acquisition_channel,
    users_acquired,
    cast(users_acquired * 100.0 / sum(users_acquired) over() as decimal(10,2)) as channel_contribution
from users_acq

/* BUSINESS FINDINGS :  
        Organic Search is LearnFlow's largest acquisition channel,contributing 25.27% of new users, followed by Paid Search at 15.93%. Together,
        search-based channels account for 41.20% of user acquisition, indicating that search is a major driver of LearnFlow's user growth.
*/


-- =========================================================
-- 3. Which acquisition channels bring the most valuable users?
-- =========================================================


with users_info as (
SELECT
     [user_id],
     acquisition_channel
    FROM dbt.dim_users),
engagement AS (
SELECT
    user_id,
    SUM(event_count) AS total_events,
    SUM(total_sessions) AS total_sessions,
    SUM(total_session_duration_minutes) AS total_session_minutes
FROM dbt.mart_user_engagement
GROUP BY user_id),
subscriptions AS (
    SELECT DISTINCT
        user_id
    FROM dbt.mart_subscription_conversion
    WHERE is_subscriber = 1),
channel_analysis AS (
SELECT
    u.acquisition_channel,
    COUNT(DISTINCT u.[user_id]) AS users_acquired,
    COUNT(DISTINCT e.[user_id]) AS active_users,
    COUNT(DISTINCT s.[user_id]) AS subscribers,
    SUM(COALESCE(e.total_events, 0)) AS total_events,
    SUM(COALESCE(e.total_sessions, 0)) AS total_sessions,
    SUM(COALESCE(e.total_session_minutes, 0)) AS total_session_minutes
FROM users_info u
LEFT JOIN engagement e
ON u.user_id = e.user_id
LEFT JOIN subscriptions s
ON u.user_id = s.user_id
GROUP BY u.acquisition_channel)

SELECT
    acquisition_channel,
    users_acquired,
    active_users,
    subscribers, 
    CAST(active_users * 100.0 / NULLIF(users_acquired, 0) AS DECIMAL(10,2)) AS activation_rate,
    CAST(subscribers * 100.0 / NULLIF(users_acquired, 0) AS DECIMAL(10,2)) AS subscriber_conversion_rate,
    CAST(total_events * 1.0 / NULLIF(active_users, 0) AS DECIMAL(10,2)) AS events_per_active_user,
    CAST(total_sessions * 1.0/ NULLIF(active_users, 0) AS DECIMAL(10,2)) AS sessions_per_active_user,
    CAST(total_session_minutes * 1.0 / NULLIF(active_users, 0) AS DECIMAL(10,2)) AS minutes_per_active_user
FROM channel_analysis
ORDER BY subscriber_conversion_rate DESC;

/* BUSINESS FINDINGS :  
       Organic Search is LearnFlow's largest acquisition source, but acquisition volume does not directly correspond to subscription conversion. 
       Instagram has the highest conversion rate at 7.90%, while Referral has the lowest at 6.89%. However, engagement levels are relatively consistent across channels,
       suggesting that differences in conversion are not accompanied by large differences in observed platform engagement.
*/



-- =========================================================
-- Which skill level segments are the most engaged with LearnFlow?
-- =========================================================

WITH user_engagement AS (
SELECT
    user_id,
    SUM(total_sessions) AS total_sessions,
    SUM(total_session_duration_minutes) AS total_session_minutes,
    SUM(event_count) AS total_events
FROM dbt.mart_user_engagement
GROUP BY user_id)

SELECT
    u.skill_level,
    COUNT(DISTINCT u.user_id) AS total_users,
    CAST(AVG(e.total_sessions * 1.0) AS DECIMAL(10,2)) AS avg_sessions_per_user,
    CAST(AVG(e.total_session_minutes * 1.0) AS DECIMAL(10,2)) AS avg_session_minutes_per_user,
    CAST(AVG(e.total_events * 1.0) AS DECIMAL(10,2)) AS avg_events_per_user
FROM dbt.dim_users u
JOIN user_engagement e
ON u.user_id = e.user_id
GROUP BY u.skill_level
ORDER BY avg_events_per_user DESC;

/* BUSINESS FINDING :
                Engagement is remarkably consistent across skill levels. Beginners make up the largest user segment,
                but engagement levels across beginner, intermediate, and advanced users are nearly identical. 
                This suggests that skill level is not a strong differentiator of platform engagement in the current dataset.
*/


-- =========================================================
-- Which age group segments are the most engaged with LearnFlow?
-- =========================================================

WITH user_engagement AS (
SELECT
    user_id,
    SUM(total_sessions) AS total_sessions,
    SUM(total_session_duration_minutes) AS total_session_minutes,
    SUM(event_count) AS total_events
FROM dbt.mart_user_engagement
GROUP BY user_id)

SELECT
    u.age_group,
    COUNT(DISTINCT u.user_id) AS total_users,
    CAST(AVG(e.total_sessions * 1.0) AS DECIMAL(10,2)) AS avg_sessions_per_user,
    CAST(AVG(e.total_session_minutes * 1.0) AS DECIMAL(10,2)) AS avg_session_minutes_per_user,
    CAST(AVG(e.total_events * 1.0) AS DECIMAL(10,2)) AS avg_events_per_user
FROM dbt.dim_users u
JOIN user_engagement e
ON u.user_id = e.user_id
GROUP BY u.age_group
ORDER BY avg_events_per_user DESC;

/* BUSINESS FINDING :
                Users aged 35–44 demonstrate the highest engagement across sessions, 
                time spent, and event activity, while engagement declines among users aged 45 and above. 
                his suggests age may be a more meaningful engagement segmentation than skill level for LearnFlow.
*/



-- =========================================================
-- COURSE PERFORMANCE
-- =========================================================

-- =========================================================
-- Which courses have the weakest learner progress, and how does their performance compare with the course catalog benchmark?
-- =========================================================

with course_performance as (
SELECT
    course_id,
    COUNT(DISTINCT user_id) AS total_learners,
    CAST(AVG(course_progress_rate)AS DECIMAL(10,2)) AS avg_progress_rate
FROM dbt.mart_user_course_performance
GROUP BY course_id),
benchmarks AS (
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_learners) OVER () AS median_learners,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_progress_rate) OVER () AS median_progress
FROM course_performance)

SELECT
    cp.course_id,
    cp.total_learners,
    cp.avg_progress_rate,
    b.median_learners,
    b.median_progress,
    CASE
        WHEN cp.total_learners >= b.median_learners AND cp.avg_progress_rate < b.median_progress THEN 'High Demand - Low Progress'
        WHEN cp.total_learners >= b.median_learners AND cp.avg_progress_rate >= b.median_progress THEN 'High Demand - Strong Progress'
        ELSE 'Lower Demand'
    END AS course_segment
FROM course_performance cp
CROSS JOIN benchmarks b
ORDER BY cp.avg_progress_rate;


-- =========================================================
-- Do premium courses perform differently from free courses in learner progress and engagement?
-- =========================================================


SELECT
    course_type,
    COUNT(DISTINCT course_id) AS total_courses,
    COUNT(DISTINCT user_id) AS total_learners,
    CAST(AVG(course_progress_rate) AS DECIMAL(10,2)) AS avg_progress_rate,
    CAST(AVG(started_lessons * 1.0) AS DECIMAL(10,2)) AS avg_started_lessons,
    CAST(AVG(completed_lessons * 1.0) AS DECIMAL(10,2)) AS avg_completed_lessons
FROM dbt.mart_user_course_performance
GROUP BY course_type;

/* BUSINESS FINDING :
                Premium courses show slightly higher average learner progress than free courses (4.95% vs. 4.78%),
                while lesson starts and completions are virtually identical. 
                This suggests that premium status is not a major differentiator of learner engagement or progress in the current dataset.
*/

-- =========================================================
-- Q4.3: How does course difficulty relate to learner progress and engagement?
-- =========================================================

SELECT
    course_difficulty,
    COUNT(DISTINCT course_id) AS total_courses,
    COUNT(DISTINCT user_id) AS total_learners,
    CAST(AVG(course_progress_rate) AS DECIMAL(10,2)) AS avg_progress_rate,
    CAST(AVG(started_lessons * 1.0) AS DECIMAL(10,2)) AS avg_started_lessons,
    CAST(AVG(completed_lessons * 1.0) AS DECIMAL(10,2)) AS avg_completed_lessons
FROM dbt.mart_user_course_performance
GROUP BY course_difficulty
ORDER BY avg_progress_rate DESC;

/* BUSINESS FINDING :
                Course difficulty does not appear to be a major differentiator of learner engagement or progress. 
                Advanced and beginner courses have identical average progress at 4.89%, 
                while intermediate courses are slightly lower at 4.56%. 
                Lesson starts and completions are also nearly identical across all difficulty levels.
*/


-- =========================================================
-- LEARNING FUNNEL
-- =========================================================

-- =========================================================
-- Q5.1: Where do users drop off after entering the learning experience?
-- =========================================================

select 
    event_name,
    users_count,
    CAST((prev_users_count - users_count) * 100.0 / NULLIF(prev_users_count,0) AS decimal(10,2)) as drop_off
from(
SELECT
    event_name,
    users_count,
    LAG(users_count) OVER(ORDER BY priority) as prev_users_count
FROM dbt.mart_learning_funnel)t

/* BUSINESS FINDING :
                92.27% of users who viewed a learning path went on to start a lesson, indicating relatively strong initial engagement.
                However, another 8.33% of users who started a lesson did not reach a subsequent lesson completion. 
                Overall, 84.58% of learning-path viewers progressed to a completed lesson.
*/


-- =========================================================
-- Which skill level segments have the highest learning funnel drop-off?
-- =========================================================

WITH funnel AS (
select
    u.skill_level,
    COUNT(DISTINCT CASE
                WHEN f.event_name = 'lesson_started' THEN f.user_id
            END) AS lesson_started_users,
    COUNT(DISTINCT CASE
                WHEN f.event_name = 'lesson_completed' THEN f.user_id
            END) AS lesson_completed_users
from dbt.dim_users u
join dbt.fact_events f
on u.user_id = f.user_id and f.event_name <> 'learning_path_viewed'
group by u.skill_level
)

select
    skill_level,
    lesson_started_users,
    lesson_completed_users,
    CAST((lesson_started_users - lesson_completed_users) * 100.0 / NULLIF(lesson_started_users, 0) AS DECIMAL(10,2)) AS start_to_completion_drop_off
FROM funnel
ORDER BY start_to_completion_drop_off DESC;

/* BUSINESS FINDING :
                Learning completion drop-off is very similar across skill levels, ranging from 12.42% to 12.63%.
                Intermediate learners have the highest drop-off, but the difference is only 0.21 percentage points,
                suggesting that skill level is not a meaningful differentiator of lesson completion.
*/


-- =========================================================
-- Subscription Conversion
-- =========================================================



-- =========================================================
-- 1: What percentage of LearnFlow users convert to a subscription?
-- =========================================================


with subscribed_users as (
SELECT DISTINCT 
    user_id
FROM dbt.fact_subscriptions)

SELECT
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT s.user_id) AS subscribed_users,
    CAST(COUNT(DISTINCT s.user_id) * 100.0 / COUNT(DISTINCT u.user_id) AS DECIMAL(10,2)) AS subscription_conversion_rate
FROM dbt.dim_users u
LEFT JOIN subscribed_users s
ON u.user_id = s.user_id;

/* BUSINESS FINDING :
                LearnFlow converts 7.50% of registered users into subscribers, with 3,752 subscribers out of 50,000 users
*/

-- =========================================================
-- 2: Which acquisition channels have the highest subscription conversion rates?
-- =========================================================

with subscribed_users as (
SELECT DISTINCT 
    user_id
FROM dbt.fact_subscriptions)
SELECT
    u.acquisition_channel,
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT s.user_id) AS subscribed_users,
    CAST(COUNT(DISTINCT s.user_id) * 100.0 / COUNT(DISTINCT u.user_id) AS DECIMAL(10,2)) AS subscription_conversion_rate
FROM dbt.dim_users u
LEFT JOIN subscribed_users s
ON u.user_id = s.user_id
GROUP BY u.acquisition_channel
ORDER BY subscription_conversion_rate DESC;

/* BUSINESS FINDING :
                Instagram has the highest subscription conversion rate at 7.90%, while Referral has the lowest at 6.89%.
                However, the overall range is relatively narrow, suggesting acquisition channel is associated with only modest differences in subscription conversion.
*/


-- Q6.3: Are more engaged users more likely to subscribe?

with user_engagement AS (
select
    user_id,
    SUM(event_count) AS total_events,
    SUM(total_sessions) AS total_sessions,
    SUM(total_session_duration_minutes) AS total_session_minutes,
    SUM(lessons_completed) AS total_lessons_completed
from dbt.mart_user_engagement
group by user_id),
subscribers AS (
SELECT DISTINCT 
    user_id
FROM dbt.fact_subscriptions)

select
    CASE
        WHEN s.user_id IS NOT NULL THEN 'Subscriber'
        ELSE 'Non-subscriber'
    END AS subscription_status,
    COUNT(DISTINCT e.user_id) AS total_users,
    CAST(AVG(e.total_events * 1.0) AS DECIMAL(10,2)) AS avg_events,
    CAST(AVG(e.total_sessions * 1.0) AS DECIMAL(10,2)) AS avg_sessions,
    CAST(AVG(e.total_session_minutes * 1.0) AS DECIMAL(10,2)) AS avg_session_minutes,
    CAST(AVG(e.total_lessons_completed * 1.0) AS DECIMAL(10,2))AS avg_lessons_completed
from user_engagement e
left join subscribers s
on e.user_id = s.user_id
GROUP BY
    CASE
        WHEN s.user_id IS NOT NULL THEN 'Subscriber'
        ELSE 'Non-subscriber'
    END
ORDER BY subscription_status;

/* BUSINESS FINDING :
                Subscribers demonstrate substantially higher engagement than non-subscribers across every measured engagement metric.
                Subscribers generate 93.24 events and 23.78 sessions on average, compared with 26.92 events and 9.87 sessions among non-subscribers.
                They also spend approximately 2.4× more time on the platform and complete about 3.1× more lessons. This indicates a strong association between higher engagement and subscription status.
*/

-- =========================================================
-- Subscription Performance
-- =========================================================


-- =========================================================
-- 1: How long do LearnFlow subscribers remain subscribed?
-- =========================================================

SELECT
    COUNT(DISTINCT user_id) AS total_subscribers,
    CAST(AVG(subscription_duration_days * 1.0) AS DECIMAL(10,2)) AS avg_subscription_duration_days,
    MIN(subscription_duration_days) AS min_duration_days,
    MAX(subscription_duration_days) AS max_duration_days
FROM dbt.fact_subscriptions
WHERE subscription_duration_days IS NOT NULL;

-- =========================================================
-- Q7.2: What proportion of subscriptions are currently active versus ended?
-- =========================================================

SELECT
    status,
    COUNT(DISTINCT subscription_id) AS subscriptions,
    COUNT(DISTINCT user_id) AS subscribers,
    CAST(COUNT(DISTINCT subscription_id) * 100.0 / SUM(COUNT(DISTINCT subscription_id)) OVER () AS DECIMAL(10,2)) AS subscription_share
FROM dbt.fact_subscriptions
GROUP BY status
ORDER BY subscriptions DESC;

/* BUSINESS FINDING :
                75.75% of LearnFlow subscriptions are currently active, while 24.25% are cancelled. 
                This indicates that roughly one in four recorded subscriptions has ended, making subscription cancellation an important area for retention analysis.
*/


-- =========================================================
-- Marketing Performance
-- =========================================================


-- =========================================================
-- 1: Which marketing channels generate clicks most efficiently relative to advertising spend?
-- =========================================================
SELECT
    channel,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    CAST(SUM(clicks) * 100.0/ NULLIF(SUM(impressions), 0) AS DECIMAL(10,2)) AS ctr,
    CAST(SUM(spend) / NULLIF(SUM(clicks), 0) AS DECIMAL(10,2)
) AS cpc
FROM dbt.mart_marketing_performance
GROUP BY channel
ORDER BY cpc;

/* BUSINESS FINDING :
                Referral is the most cost efficient marketing channel, with the lowest CPC at $0.58,
                while Organic Search combines the second-lowest CPC ($0.59) with the highest CTR (2.68%).
                Paid Search is the least efficient channel by CPC at $0.68.
*/

-- =========================================================
-- 2: How is marketing efficiency changing over time?
-- =========================================================

SELECT
    campaign_month,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    CAST(SUM(clicks) * 100.0 / NULLIF(SUM(impressions), 0) AS DECIMAL(10,2)) AS ctr,
    CAST(SUM(spend) / NULLIF(SUM(clicks), 0) AS DECIMAL(10,2)) AS cpc
FROM dbt.mart_marketing_performance
GROUP BY campaign_month
ORDER BY campaign_month;

/* BUSINESS FINDING :
            Marketing efficiency remained relatively stable from January through July, with CTR generally around 2.5%–2.7% and CPC around $0.59–$0.67.
            March was the strongest month, combining the highest CTR (2.71%) with the lowest CPC ($0.59),
            while June was the weakest, with the lowest CTR (2.52%) and highest CPC ($0.67). Performance recovered in July.
*/

-- =========================================================
--  Which age groups have the highest subscription conversion rates?
-- =========================================================

SELECT
    u.age_group,
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT s.user_id) AS subscribed_users,
    CAST(COUNT(DISTINCT s.user_id) * 100.0 / COUNT(DISTINCT u.user_id) AS DECIMAL(10,2)) AS subscription_conversion_rate
FROM dbt.dim_users u
LEFT JOIN (
    SELECT DISTINCT
        user_id
    FROM dbt.fact_subscriptions
) s
ON u.user_id = s.user_id
GROUP BY u.age_group
ORDER BY subscription_conversion_rate DESC;


/* BUSINESS FINDING :
            Users aged 45–54 have the highest subscription conversion rate at 7.95%, while users aged 55+ have the lowest among the defined age groups at 6.48%. 
            The 35–44 and 25–34 groups are also close to the overall 7.50% conversion rate.
*/


-- =========================================================
--  Does subscription conversion increase with user engagement?
-- =========================================================

with user_engagement AS (
select
   user_id,
   SUM(total_sessions) AS total_sessions
from dbt.mart_user_engagement
group by user_id),
user_subscription AS (
select DISTINCT
        user_id
from dbt.fact_subscriptions),
engagement_groups AS (
select
    e.user_id,
    e.total_sessions,
    CASE
        WHEN e.total_sessions < 10 THEN 'Low engagement'
        WHEN e.total_sessions < 20 THEN 'Medium engagement'
        ELSE 'High engagement'
    END AS engagement_group
from user_engagement e)
SELECT
    eg.engagement_group,
    COUNT(DISTINCT eg.user_id) AS total_users,
    COUNT(DISTINCT s.user_id) AS subscribers,
    CAST(COUNT(DISTINCT s.user_id) * 100.0 / COUNT(DISTINCT eg.user_id)AS DECIMAL(10,2)) AS subscription_conversion_rate

FROM engagement_groups eg
LEFT JOIN user_subscription s
ON eg.user_id = s.user_id
GROUP BY eg.engagement_group
ORDER BY subscription_conversion_rate DESC;

/* BUSINESS FINDING :
            Subscription conversion is strongly associated with user engagement. 
            Highly engaged users convert at 26.42%, compared with 5.75% for medium-engagement users and only 0.68% for low-engagement users. 
            This suggests that increasing meaningful user engagement could be an important area for subscription growth, although the analysis does not establish a causal relationship.
*/