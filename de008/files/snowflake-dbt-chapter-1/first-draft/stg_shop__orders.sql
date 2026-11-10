with source as (
    select * from {{ source('shop', 'orders') }}
),

renamed as (
    select
        source.order_id,
        source.customer_id,
        cast(source.order_ts as timestamp) as ordered_at,
        source.status as order_status,
        cast(source.amount_gbp as numeric(10, 2)) as amount_gbp
    from source
)

select * from renamed
