{{ config(materialized='table') }}

with customers_raw as (
    select * from {{ source('olist_raw', 'customers') }}
),

geolocation as (
    select * from {{ source('olist_raw', 'geolocation') }}
),

customers_enhanced as (
    select
        -- Primary identifiers
        c.customer_id,
        c.customer_unique_id as customer_key,
        
        -- Location details
        c.customer_zip_code_prefix as zip_code_prefix,
        c.customer_city as city,
        c.customer_state as state,
        
        -- Enhanced location from geolocation table
        g.geolocation_lat as latitude,
        g.geolocation_lng as longitude,
        
        -- Metadata
        current_timestamp as created_at
        
    from customers_raw c
    left join geolocation g 
        on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
        and c.customer_city = g.geolocation_city
        and c.customer_state = g.geolocation_state
)

select * from customers_enhanced