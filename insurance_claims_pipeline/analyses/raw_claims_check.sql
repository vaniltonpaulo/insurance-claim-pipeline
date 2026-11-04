SELECT COUNT(*)
FROM FROM {{ source('bronze', 'raw_claims') }}