with claims as (
    select
        -- Claim surrogate key using policy_number + incident_date
        {{ dbt_utils.generate_surrogate_key(['policy_number', 'incident_date']) }} as claim_key,
        -- Foreign keys to dimension tables
        {{ dbt_utils.generate_surrogate_key(['policy_number']) }} as customer_key,
        {{ dbt_utils.generate_surrogate_key(['policy_number']) }} as vehicle_key,
        {{ dbt_utils.generate_surrogate_key(['policy_number']) }} as policy_key,
        policy_number,
        incident_date,
        incident_type,
        collision_type,
        incident_severity,
        incident_state,
        incident_city,
        authorities_contacted,
        number_of_vehicles_involved,
        property_damage,
        bodily_injuries,
        witnesses,
        police_report_available,
        -- Measure columns
        total_claim_amount,
        injury_claim,
        property_claim,
        vehicle_claim,
        is_fraud
    from {{ ref('stg_claims') }}
)

select * from claims
