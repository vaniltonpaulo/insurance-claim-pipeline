with customers as (
    select distinct
        -- Generate a surrogate key from policy_number
        {{ dbt_utils.generate_surrogate_key(['policy_number']) }} as customer_key,
        policy_number,
        customer_age,
        insured_sex,
        insured_education_level,
        insured_occupation,
        insured_relationship,
        months_as_customer,
        capital_gains,
        capital_loss
    from {{ ref('stg_claims') }}
)

select * from customers