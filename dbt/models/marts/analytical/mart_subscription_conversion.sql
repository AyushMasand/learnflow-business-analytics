{{ config(materialized='table') }}

with user_subscriptions as (
    select
        u.user_id,
        u.signup_date,
        u.country,
        u.age_group,
        u.acquisition_channel,
        u.device_type,
        u.learning_goal,
        u.skill_level,
        s.subscription_id,
        s.[plan] as subscription_plan,
        s.start_date,
        s.end_date,
        s.monthly_price,
        s.status,
        s.subscription_start_date,
        s.subscription_start_month,
        s.subscription_duration_days
    from {{ ref('dim_users') }} u
    left join {{ ref('fact_subscriptions') }} s
    on u.user_id = s.user_id),
trial_events as (
    select
        user_id,
        min(event_timestamp) as first_trial_started_time
    from {{ ref('fact_events') }}
    where event_name = 'trial_started'
    group by user_id)
select
    us.user_id,
    us.signup_date,
    us.country,
    us.age_group,
    us.acquisition_channel,
    us.device_type,
    us.learning_goal,
    us.skill_level,
    us.subscription_id,
    us.subscription_plan,
    us.start_date,
    us.end_date,
    us.monthly_price,
    us.status,
    us.subscription_start_date,
    us.subscription_start_month,
    us.subscription_duration_days,
    case
        when us.subscription_id is not null then 1
        else 0
    end as is_subscriber,
    case
        when te.first_trial_started_time is not null then 1
        else 0
    end as started_trial,
    te.first_trial_started_time,
    case
        when te.first_trial_started_time is not null
         and us.start_date is not null
         and us.start_date > te.first_trial_started_time
        then 1
        else 0
    end as trial_to_subscription
from user_subscriptions us
left join trial_events te
on us.user_id = te.user_id