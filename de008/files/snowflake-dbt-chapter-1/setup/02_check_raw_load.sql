-- After loading the two CSVs with Snowsight's Load Data dialog (header line treated as the header).

-- 1. Row count, and the header line did not arrive as a data row (expect 5012 and 0).
select count(*) as file_rows
from shop_dev.raw.orders;

select count(*) as header_rows_loaded_as_data
from shop_dev.raw.orders as orders
where orders.order_id = 'order_id';

-- 2. Repeated order ids.
select
    orders.order_id,
    count(*) as copies
from shop_dev.raw.orders as orders
group by orders.order_id
having count(*) > 1;

-- 3. Are the repeats exact copies? If distinct whole rows = distinct order ids,
--    every repeated id is an identical row (expect 5012 / 5000 / 5000).
select
    count(*) as file_rows,
    count(distinct orders.order_id) as distinct_order_ids,
    (select count(*) from (select distinct * from shop_dev.raw.orders)) as distinct_whole_rows
from shop_dev.raw.orders as orders;

-- 4. Status values as delivered.
select
    orders.status,
    count(*) as order_rows
from shop_dev.raw.orders as orders
group by orders.status
order by orders.status;
