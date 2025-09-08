{{ config(materialized='table') }}

with customer_daily_orders as (
    select
        -- Customer identifiers
        customer_unique_id,
        customer_id,
        customer_city,
        customer_state,
        
        -- Activity date (extracted from order purchase timestamp)
        date(order_purchase_timestamp) as activity_date,
        
        -- Order counts by status
        count(*) as order_created_count,
        
        count(case 
            when order_status_grouped in ('completed', 'in_transit', 'processing') 
            then 1 
        end) as order_paid_count,
        
        count(case 
            when order_status_grouped = 'completed' 
            then 1 
        end) as order_done_count,
        
        -- Payment aggregates
        sum(total_payment_value) as total_payment_value_sum,
        sum(voucher_value) as voucher_value_sum
        
    from {{ ref('stg_orders') }}
    where order_purchase_timestamp is not null
    group by 
        customer_unique_id,
        customer_id,
        customer_city,
        customer_state,
        date(order_purchase_timestamp)
)

select * from customer_daily_orders
order by customer_unique_id, activity_date