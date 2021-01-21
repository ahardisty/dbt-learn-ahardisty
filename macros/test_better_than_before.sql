{% macro test_better_than_before(
    model,
    column_name,
    date_or_ts_column
) %}
with orders as (
    select * from {{ model }}
),
order_days as (
    select
        {{ date_or_ts_column }}::date as date_day,
        sum({{ column_name }}) as daily_total
    from orders
    group by 1
),
previous_three as (
    select *,
        avg(daily_total) over (
            order by date_day
            rows between 4 preceding and 1 preceding
        ) as previous_3_order_amount_avg
    from order_days
)
select count(*) from previous_three
where daily_total < previous_3_order_amount_avg
{% endmacro %}