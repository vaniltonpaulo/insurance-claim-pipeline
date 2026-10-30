with policies as (
    select distinct
        -- Surrogate key for policy dimension
        {{ dbt_utils.generate_surrogate_key(['policy_number']) }} as policy_key,
        policy_number,
        policy_state,
        policy_csl,
        policy_deductible,
        policy_annual_premium,
        umbrella_limit
    from {{ ref('stg_claims') }}
)

select * from policies