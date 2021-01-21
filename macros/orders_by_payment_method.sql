{% set payment_methods = ["bank_transfer", "credit_card", "gift_card"] %}

with payments AS (
    select * from {{ ref('stg_payments') }}
),

pivoted AS
(
select
ORDERID AS order_id,
{% for paymentmethod in payment_methods %}

sum(case when paymentmethod = '{{payment_method}}' then amount end) as {{paymentmethod}}_amount

{% if not loop.last %},{%- endif -%}
{% endfor %}

from {{ ref('stg_payments') }}
group by 1
)

select * from payments