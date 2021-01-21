{# select * from {{ source('stripe', 'payment') }} #}
select * from raw.stripe.payment