SELECT policy_number, incident_state
FROM insurance.silver.stg_claims
WHERE incident_state IS NULL;