{{
  config(
    materialized = 'table',
  )
}}

with
base_dates as (
  {{
    dbt.date_spine(
      'day',
      "DATE('2016-01-01')",
      "DATE('2030-12-31')"
    )
  }}
),
final as (
  select
    cast(date_day as date) as date_day
  from base_dates
)

select *
from final
where date_day > current_date - interval '9 years'
  and date_day < current_date + interval '6 months'