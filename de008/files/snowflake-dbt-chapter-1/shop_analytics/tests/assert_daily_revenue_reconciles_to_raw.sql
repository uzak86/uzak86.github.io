-- Fails (returns a row) if the mart's completed revenue differs from the raw file
-- after removing repeated rows and normalising status, OR if either total is missing.
-- This fixture expects completed revenue on both sides, so a missing total is a failure.
-- (For periods that can legitimately have no sales, define that policy explicitly;
-- don't coalesce every missing total to zero.)
with raw_orders as (
    select distinct * from {{ source('shop', 'orders') }}
),

raw_total as (
    select sum(cast(raw_orders.amount_gbp as numeric(10, 2))) as total_gbp
    from raw_orders
    where lower(trim(raw_orders.status)) = 'completed'
),

mart_total as (
    select sum(fct_daily_revenue.completed_revenue_gbp) as total_gbp
    from {{ ref('fct_daily_revenue') }} as fct_daily_revenue
)

select
    raw_total.total_gbp as raw_total_gbp,
    mart_total.total_gbp as mart_total_gbp
from raw_total
cross join mart_total
where raw_total.total_gbp is null
   or mart_total.total_gbp is null
   or raw_total.total_gbp <> mart_total.total_gbp
