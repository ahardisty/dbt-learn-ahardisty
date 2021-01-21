/* What if this is a dynamically updating list of payment methods? */
/* pull out all current distinct values of payment_method */
{% set get_payment_methods_sql %}
    select distinct payment_method from {{ ref('stg_payments') }}
{% endset %}
{% set results = run_query(get_payment_methods_sql) %}
{% if execute %}
    {% set payment_methods = results.columns['PAYMENT_METHOD'].values() %}
{% endif %}
with payments as (
    select * from {{ ref('stg_payments') }}
),
pivoted as (
    select 
        order_id,
    {%- for payment_method in payment_methods %}
        sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount
    {%- if not loop.last -%}, {%- endif -%}
        {% endfor %}
    from payments
    group by 1
)
select * from pivoted