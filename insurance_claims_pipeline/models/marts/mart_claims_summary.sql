with claims as (
    select * from {{ ref('fact_claims') }}
),

summary as (
    select
        incident_state,
        incident_severity,
        -- Claim volume metrics
        count(*) as total_claims,
        round(avg(total_claim_amount), 2) as avg_claim_amount,
        round(sum(total_claim_amount), 2) as total_claim_value,
        -- Fraud metrics
        sum(case when is_fraud then 1 else 0 end) as fraud_count,
        round(
            sum(case when is_fraud then 1 else 0 end) * 100.0 / count(*),
            2
        ) as fraud_rate_pct,
        -- Injury and witness averages
        round(avg(bodily_injuries), 2) as avg_bodily_injuries,
        round(avg(witnesses), 2) as avg_witnesses
    from claims
    group by incident_state, incident_severity
)

select * from summary