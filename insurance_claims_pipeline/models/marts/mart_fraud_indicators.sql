with claims as (
    select * from {{ ref('fact_claims') }}
),

percentiles as (
    -- Calculate the 90th percentile threshold for claim amounts
    select
        percentile_approx(total_claim_amount, 0.90) as p90_claim_amount
    from claims
),

fraud_signals as (
    select
        c.claim_key,
        c.policy_number,
        c.incident_date,
        c.incident_type,
        c.incident_severity,
        c.incident_state,
        c.total_claim_amount,
        c.is_fraud,
        -- Individual fraud risk flags
        case when c.total_claim_amount > p.p90_claim_amount then 1 else 0 end as high_claim_flag,
        case when c.witnesses = 0 then 1 else 0 end as zero_witnesses_flag,
        case when c.police_report_available = 'NO' then 1 else 0 end as no_police_report_flag,
        case when c.property_damage = 'NO' then 1 else 0 end as no_property_damage_flag,
        -- Composite risk score (sum of all flags, 0-4)
        (
            case when c.total_claim_amount > p.p90_claim_amount then 1 else 0 end
            + case when c.witnesses = 0 then 1 else 0 end
            + case when c.police_report_available = 'NO' then 1 else 0 end
            + case when c.property_damage = 'NO' then 1 else 0 end
        ) as risk_score
    from claims c
    cross join percentiles p
)

select * from fraud_signals