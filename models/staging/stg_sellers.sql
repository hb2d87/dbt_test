{{ config(materialized='table') }}

with sellers_raw as (
    select * from {{ source('olist_raw', 'sellers') }}
),

geolocation as (
    select * from {{ source('olist_raw', 'geolocation') }}
),

sellers_enhanced as (
    select
        -- Primary identifier
        s.seller_id,
        
        -- Location details
        s.seller_zip_code_prefix as zip_code_prefix,
        s.seller_city as city,
        s.seller_state as state,
        
        -- Enhanced location from geolocation table
        g.geolocation_lat as latitude,
        g.geolocation_lng as longitude,
        
        -- Metadata
        current_timestamp as created_at
        
    from sellers_raw s
    left join geolocation g 
        on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
        and s.seller_city = g.geolocation_city
        and s.seller_state = g.geolocation_state
)

select * from sellers_enhanced