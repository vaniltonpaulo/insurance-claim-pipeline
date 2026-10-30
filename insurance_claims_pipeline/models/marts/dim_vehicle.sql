with vehicles as (
    select distinct
        -- Surrogate key for vehicle dimension
        {{ dbt_utils.generate_surrogate_key(['policy_number']) }} as vehicle_key,
        policy_number,
        auto_make,
        auto_model,
        auto_year
    from {{ ref('stg_claims') }}
)

select * from vehicles