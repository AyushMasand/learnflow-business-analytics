select 
    *
from {{ref('fact_marketing')}}
where clicks > impressions