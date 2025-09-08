{{ config(materialized='table') }}

with product_daily_sales as (
    select
        -- Product identifiers
        oi.product_id,
        oi.category_english,
        
        -- Activity date (extracted from order purchase timestamp)
        date(o.order_purchase_timestamp) as activity_date,
        
        -- Sales metrics
        count(oi.order_item_id) as items_sold_count,
        sum(oi.item_price) as total_item_price,
        sum(oi.freight_value) as total_freight_value,
        sum(oi.total_item_value) as total_item_value_sum
        
    from {{ ref('stg_order_items') }} oi
    inner join {{ ref('stg_orders') }} o on oi.order_id = o.order_id
    where o.order_purchase_timestamp is not null
    group by 
        oi.product_id,
        oi.category_english,
        date(o.order_purchase_timestamp)
)

select * from product_daily_sales
order by product_id, activity_date