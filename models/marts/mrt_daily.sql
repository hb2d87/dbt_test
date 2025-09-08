{{ config(materialized='table') }}

with customer_daily_summary as (
    select
        -- Geographic dimensions
        customer_state,
        customer_city,
        
        -- Time dimension
        activity_date,
        'daily' as date_granulation,
        
        -- Customer dimension
        count(distinct customer_unique_id) as active_users_count,
        
        -- Activity metrics
        sum(order_created_count) as order_created_count,
        sum(order_done_count) as order_done_count,
        
        -- Financial metrics
        sum(total_payment_value_sum) as total_payment_value_sum,
        sum(voucher_value_sum) as voucher_value_sum,
        sum(total_payment_value_sum) - sum(voucher_value_sum) as net_payment_value
        
    from {{ ref('int_customer_daily_activity') }}
    group by 
        customer_state,
        customer_city,
        activity_date
)

select * from customer_daily_summary
order by activity_date desc, customer_state, customer_city