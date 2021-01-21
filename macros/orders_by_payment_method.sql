/* What if this is a dynamically updating list of payment methods? */
/* pull out all current distinct values of payment_method */
{% set get_payment_methods_sql %}
SELECT
    DISTINCT payment_method
FROM
    {{ ref('stg_payments') }}

    {% endset %}

    {% set results = run_query(get_payment_methods_sql) %}
    {% if execute %}
        {% set payment_methods = results.columns ['PAYMENT_METHOD'].values() %}
    {% endif %}

    WITH payments AS (
        SELECT
            *
        FROM
            {{ ref('stg_payments') }}
    ),
    pivoted AS (
        SELECT
            order_id,
            {%- for payment_method in payment_methods %}
                SUM(
                    CASE
                        WHEN payment_method = '{{ payment_method }}' THEN amount
                        ELSE 0
                    END
                ) AS {{ payment_method }}
                _amount

                {%- if not loop.last -%},
            {%- endif -%}
        {% endfor %}
        FROM
            payments
        GROUP BY
            1
    )
SELECT
    *
FROM
    pivoted
