{{ config(materialized='table') }}

select
    campaign_id,
    campaign_date,
    campaign_month,
    channel,
    campaign,
    spend,
    impressions,
    clicks,
    ctr,
    cpc
from {{ ref('fact_marketing') }}