with source as (
    select * from {{ source('shop', 'customers') }}
),

renamed as (
    select
        source.customer_id,
        cast(source.signup_date as date) as signed_up_on,
        source.country as country_code
    from source
)

select * from renamed
