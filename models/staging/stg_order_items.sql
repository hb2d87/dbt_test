{{ config(materialized='table') }}

with order_items_raw as (
    select * from {{ source('olist_raw', 'order_items') }}
),

products as (
    select * from {{ source('olist_raw', 'products') }}
),

category_translation as (
    select * from {{ source('olist_raw', 'product_category_name_translation') }}
),

order_items_enhanced as (
    select
        -- Foreign keys
        oi.order_id,
        oi.product_id,
        oi.seller_id,
        
        -- Item details
        oi.order_item_id,
        oi.shipping_limit_date,
        oi.price as item_price,
        oi.freight_value,
        oi.price + oi.freight_value as total_item_value,
        
        -- Product information
        p.product_category_name as category_portuguese,
        coalesce(ct.product_category_name_english, p.product_category_name) as category_english,
        
        -- Product attributes
        p.product_name_lenght as product_name_length,
        p.product_description_lenght as product_description_length,
        p.product_photos_qty as product_photos_count,
        p.product_weight_g as product_weight_grams,
        p.product_length_cm as product_length_cm,
        p.product_height_cm as product_height_cm,
        p.product_width_cm as product_width_cm,
        
        -- Calculated product dimensions
        (p.product_length_cm * p.product_height_cm * p.product_width_cm) as product_volume_cm3,
        
        -- Product categorization
        case 
            when p.product_weight_g < 500 then 'light'
            when p.product_weight_g between 500 and 2000 then 'medium'
            when p.product_weight_g > 2000 then 'heavy'
            else 'unknown'
        end as weight_category,
        
        case 
            when (p.product_length_cm * p.product_height_cm * p.product_width_cm) < 1000 then 'small'
            when (p.product_length_cm * p.product_height_cm * p.product_width_cm) between 1000 and 10000 then 'medium'
            when (p.product_length_cm * p.product_height_cm * p.product_width_cm) > 10000 then 'large'
            else 'unknown'
        end as size_category,
        
        -- Price analysis
        case 
            when oi.price < 20 then 'low'
            when oi.price between 20 and 100 then 'medium'
            when oi.price between 100 and 300 then 'high'
            when oi.price > 300 then 'premium'
            else 'unknown'
        end as price_category,
        
        -- Shipping analysis
        round((oi.freight_value / nullif(oi.price, 0)) * 100, 2) as shipping_percentage_of_price,
        
        -- Metadata
        current_timestamp as created_at
        
    from order_items_raw oi
    left join products p on oi.product_id = p.product_id
    left join category_translation ct on p.product_category_name = ct.product_category_name
)

select * from order_items_enhanced