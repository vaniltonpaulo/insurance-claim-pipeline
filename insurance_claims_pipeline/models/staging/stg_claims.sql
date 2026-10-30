-- Pull all columns from the Bronze source
WITH source AS (
    SELECT *
    FROM {{ source('bronze', 'raw_claims') }}
),

cleaned AS (
    SELECT
        -- Policy identifiers
        CAST(policy_number AS STRING) AS policy_number,
        TRY_CAST(months_as_customer AS INT) AS months_as_customer,
        TRY_CAST(age AS INT) AS customer_age,

        -- Policy details
        UPPER(TRIM(policy_state)) AS policy_state,
        TRIM(policy_csl) AS policy_csl,
        TRY_CAST(policy_deductable AS INT) AS policy_deductible,
        TRY_CAST(policy_annual_premium AS DOUBLE) AS policy_annual_premium,
        TRY_CAST(umbrella_limit AS INT) AS umbrella_limit,

        -- Customer demographics
        TRIM(insured_sex) AS insured_sex,
        TRIM(insured_education_level) AS insured_education_level,
        TRIM(insured_occupation) AS insured_occupation,
        TRIM(insured_relationship) AS insured_relationship,
        TRY_CAST(`capital-gains` AS INT) AS capital_gains,
        TRY_CAST(`capital-loss` AS INT) AS capital_loss,

        -- Incident details
        TRY_CAST(incident_date AS DATE) AS incident_date,
        TRIM(incident_type) AS incident_type,
        TRIM(collision_type) AS collision_type,
        TRIM(incident_severity) AS incident_severity,
        TRIM(authorities_contacted) AS authorities_contacted,
        UPPER(TRIM(incident_state)) AS incident_state,
        TRIM(incident_city) AS incident_city,
        TRY_CAST(number_of_vehicles_involved AS INT) AS number_of_vehicles_involved,
        TRIM(property_damage) AS property_damage,
        TRY_CAST(bodily_injuries AS INT) AS bodily_injuries,
        TRY_CAST(witnesses AS INT) AS witnesses,
        TRIM(police_report_available) AS police_report_available,

        -- Claim amounts
        TRY_CAST(total_claim_amount AS DOUBLE) AS total_claim_amount,
        TRY_CAST(injury_claim AS DOUBLE) AS injury_claim,
        TRY_CAST(property_claim AS DOUBLE) AS property_claim,
        TRY_CAST(vehicle_claim AS DOUBLE) AS vehicle_claim,

        -- Vehicle information
        TRIM(auto_make) AS auto_make,
        TRIM(auto_model) AS auto_model,
        TRY_CAST(auto_year AS INT) AS auto_year,

        -- Convert fraud flag to boolean
        CASE
            WHEN UPPER(TRIM(fraud_reported)) = 'Y' THEN TRUE
            WHEN UPPER(TRIM(fraud_reported)) = 'N' THEN FALSE
            ELSE NULL
        END AS is_fraud,

        -- Preserve Bronze metadata
        _ingested_at,
        _source_file

    FROM source
)

SELECT *
FROM cleaned
