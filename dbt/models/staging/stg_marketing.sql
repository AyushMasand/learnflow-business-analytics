{{ config(materialized='view') }}

select
    CAST(campaign_id AS VARCHAR(30)) AS campaign_id,
    CAST(date AS DATE) AS campaign_date,
    CAST(channel AS VARCHAR(50)) AS channel,
    CAST(campaign AS VARCHAR(100)) AS campaign,
    CAST(spend AS DECIMAL(14,2)) AS spend,
    CAST(impressions AS BIGINT) AS impressions,
    CAST(clicks AS BIGINT) AS clicks
from {{ source('raw', 'marketing') }}
where spend >= 0
  AND impressions >= 0
  AND clicks >= 0
  AND clicks <= impressions