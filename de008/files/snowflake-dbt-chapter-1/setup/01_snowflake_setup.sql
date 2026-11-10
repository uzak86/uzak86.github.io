-- Run once in a Snowsight worksheet as a role that can create warehouses, databases and roles
-- (in a new trial account: ACCOUNTADMIN). Synthetic course data only.
create warehouse if not exists transform_wh
    warehouse_size = 'XSMALL'
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;

create database if not exists shop_dev;
create schema if not exists shop_dev.raw;

create table if not exists shop_dev.raw.orders (
    order_id varchar,
    customer_id varchar,
    order_ts varchar,
    status varchar,
    amount_gbp varchar
);

create table if not exists shop_dev.raw.customers (
    customer_id varchar,
    signup_date varchar,
    country varchar
);

-- The role dbt connects as: read the raw tables, build its own schema in shop_dev.
create role if not exists transformer;
grant usage on warehouse transform_wh to role transformer;
grant usage, create schema on database shop_dev to role transformer;
grant usage on schema shop_dev.raw to role transformer;
grant select on all tables in schema shop_dev.raw to role transformer;
set my_user = '"' || current_user() || '"';
grant role transformer to user identifier($my_user);
