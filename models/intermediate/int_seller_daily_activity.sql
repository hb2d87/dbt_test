{{ config(materialized='table') }}

with seller_daily_performance as (
    select
        -- Seller identifier
        oi.seller_id,
        
        -- Activity date (extracted from order purchase timestamp)
        date(o.order_purchase_timestamp) as activity_date,
        
        -- Order metrics
        count(distinct oi.order_id) as orders_received_count,
        count(oi.order_item_id) as items_sold_count,
        
        -- Delivery performance
        count(case 
            when o.order_status_grouped = 'completed' 
            then oi.order_item_id 
        end) as items_delivered_count,
        
        count(case 
            when o.order_status_grouped in ('in_transit', 'processing') 
            then oi.order_item_id 
        end) as items_in_progress_count,
        
        -- Revenue metrics
        sum(oi.item_price) as total_item_revenue,
        sum(oi.freight_value) as total_freight_revenue,
        sum(oi.total_item_value) as total_order_value,
        
        -- Performance metrics
        avg(oi.item_price) as avg_item_price,
        avg(oi.freight_value) as avg_freight_value,
        
        -- Product diversity
        count(distinct oi.product_id) as unique_products_sold,
        count(distinct oi.category_english) as unique_categories_sold
        
    from {{ ref('stg_order_items') }} oi
    inner join {{ ref('stg_orders') }} o on oi.order_id = o.order_id
    where o.order_purchase_timestamp is not null
      and oi.seller_id is not null
    group by 
        oi.seller_id,
        date(o.order_purchase_timestamp)
)

select * from seller_daily_performance
order by seller_id, activity_date