{{ config(materialized='table') }}

with orders_raw as (
    select * from {{ source('olist_raw', 'orders') }}
),

order_payments as (
    select 
        order_id,
        sum(payment_value) as total_payment_value,
        sum(case when payment_type = 'voucher' then payment_value else 0 end) as voucher_value,
        count(distinct payment_type) as payment_methods_count,
        string_agg(distinct payment_type, ', ') as payment_types
    from {{ source('olist_raw', 'order_payments') }}
    group by order_id
),

customers as (
    select * from {{ ref('stg_customers') }}
),

orders_final as (
    select
        -- Primary identifiers
        o.order_id,
        o.customer_id,
        c.customer_key,
        
        -- Order status and classification
        o.order_status,
        case 
            when o.order_status = 'delivered' then 'completed'
            when o.order_status = 'shipped' then 'in_transit'
            when o.order_status = 'canceled' then 'cancelled'
            when o.order_status = 'unavailable' then 'cancelled'
            when o.order_status = 'invoiced' then 'processing'
            when o.order_status = 'processing' then 'processing'
            when o.order_status = 'approved' then 'processing'
            when o.order_status = 'created' then 'created'
            else 'other'
        end as order_status_grouped,
        
        -- Cancellation reason
        case 
            when o.order_status = 'canceled' then 'customer_cancelled'
            when o.order_status = 'unavailable' then 'product_unavailable'
            else null
        end as cancellation_reason,
        
        -- Timestamps
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        
        -- Delivery performance
        case 
            when o.order_delivered_customer_date is not null 
                 and o.order_estimated_delivery_date is not null
            then case 
                when o.order_delivered_customer_date <= o.order_estimated_delivery_date 
                then true 
                else false 
            end
            else null
        end as delivered_on_time,
        
        case 
            when o.order_delivered_customer_date is not null 
                 and o.order_purchase_timestamp is not null
            then extract(day from (o.order_delivered_customer_date - o.order_purchase_timestamp))
            else null
        end as days_to_delivery,
        
        -- Customer location
        c.city as customer_city,
        c.state as customer_state,
        c.zip_code_prefix as customer_zip_code_prefix,
        
        -- Payment information
        coalesce(p.total_payment_value, 0) as total_payment_value,
        coalesce(p.voucher_value, 0) as voucher_value,
        p.payment_methods_count,
        p.payment_types,
        
        -- Metadata
        current_timestamp as created_at
        
    from orders_raw o
    left join customers c on o.customer_id = c.customer_id
    left join order_payments p on o.order_id = p.order_id
)

select * from orders_final