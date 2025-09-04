{{ config(materialized='table') }}

with order_payments_raw as (
    select * from {{ source('olist_raw', 'order_payments') }}
),

payments_enhanced as (
    select
        -- Foreign key
        order_id,
        
        -- Payment details
        payment_sequential,
        payment_type,
        case 
            when payment_type = 'credit_card' then 'Credit Card'
            when payment_type = 'boleto' then 'Bank Slip (Boleto)'
            when payment_type = 'voucher' then 'Voucher'
            when payment_type = 'debit_card' then 'Debit Card'
            when payment_type = 'not_defined' then 'Not Defined'
            else initcap(payment_type)
        end as payment_type_display,
        
        payment_installments,
        payment_value,
        
        -- Payment categorization
        case 
            when payment_type in ('credit_card', 'debit_card') then 'card'
            when payment_type = 'boleto' then 'bank_transfer'
            when payment_type = 'voucher' then 'voucher'
            else 'other'
        end as payment_category,
        
        -- Installment categorization
        case 
            when payment_installments = 1 then 'single_payment'
            when payment_installments between 2 and 6 then 'short_term_installments'
            when payment_installments between 7 and 12 then 'medium_term_installments'
            when payment_installments > 12 then 'long_term_installments'
            else 'unknown'
        end as installment_category,
        
        -- Metadata
        current_timestamp as created_at
        
    from order_payments_raw
)

select * from payments_enhanced