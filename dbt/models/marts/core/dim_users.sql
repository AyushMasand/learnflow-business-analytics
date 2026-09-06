{{ config(materialized='table') }}

select
    user_id,
    signup_date,
    CAST(signup_date AS DATE) AS signup_date_only,
    DATETRUNC(MONTH,signup_date) AS signup_month,
    country,
    age_group,
    acquisition_channel,
    device_type,
    learning_goal,
    skill_level
FROM {{ ref('stg_users') }}