with orders as (
    select * from {{ ref('stg_shop__orders') }}
),

daily as (
    select
        cast(orders.ordered_at as date) as order_date,
        count(*) as orders_placed,
        sum(case when orders.order_status = 'completed' then 1 else 0 end) as completed_orders,
        sum(case when orders.order_status = 'completed' then orders.amount_gbp else 0 end) as completed_revenue_gbp,
        sum(case when orders.order_status = 'refunded' then orders.amount_gbp else 0 end) as refunded_gbp
    from orders
    group by cast(orders.ordered_at as date)
)

select * from daily
