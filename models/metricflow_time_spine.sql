-- models/metricflow_time_spine.sql
{{
    config(
        materialized='table'
    )
}}

with spine as (
    {{
        dbt.date_spine(
            'day',
            "DATE('2016-01-01')",
            "DATE('2030-01-01')"
        )
    }}
),

final as (
    select 
        cast(date_day as date) as activity_date
    from spine
    where date_day >= current_date - interval '8 years'
      and date_day < current_date + interval '2 years'
)

select * from final