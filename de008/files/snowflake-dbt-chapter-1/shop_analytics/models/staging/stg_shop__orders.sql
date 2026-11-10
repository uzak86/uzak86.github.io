with source as (
    select * from {{ source('shop', 'orders') }}
),

renamed as (
    select
        source.order_id,
        source.customer_id,
        cast(source.order_ts as timestamp) as ordered_at,
        lower(trim(source.status)) as order_status,
        cast(source.amount_gbp as numeric(10, 2)) as amount_gbp
    from source
)

select * from renamed
qualify row_number() over (partition by renamed.order_id order by renamed.ordered_at) = 1
