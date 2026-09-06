{{ config(materialized='table') }}

SELECT
    campaign_id,
    campaign_date,
    channel,
    campaign,
    spend,
    impressions,
    clicks,
    DATETRUNC(MONTH,campaign_date) as campaign_month,
    CASE
        WHEN impressions > 0 THEN CAST(clicks AS DECIMAL(18,4)) / impressions
        ELSE 0
    END AS ctr,
    CASE
        WHEN clicks > 0 THEN spend / clicks
        ELSE 0
    END AS cpc
FROM {{ ref('stg_marketing') }}