# Insurance Claims Analytics Pipeline

**End-to-end insurance claims analytics with Databricks, Delta Lake, dbt, GitHub Actions, and Tableau.**

[Explore the interactive Tableau dashboard](https://public.tableau.com/app/profile/vanilton.paulo/viz/InsuranceClaimsAnalysis_17933994207990/InsuranceClaimsAnalysis?publish=yes) · [View the source repository](https://github.com/vaniltonpaulo/insurance-claim-pipeline)

![Insurance Claims Dashboard](docs/dashboard-screenshot.png)

## Overview

Insurance claims data often arrives with inconsistent field names, mixed data types, and categorical values that need standardization before analysis. This project builds a **Medallion architecture** to transform raw auto-insurance claims into tested, analytics-ready datasets and an interactive Tableau dashboard.

The pipeline combines **PySpark ingestion**, **Delta Lake storage**, **dbt transformations and tests**, and **GitHub Actions CI**. The analytical layer is modeled for reporting on claims, customers, vehicles, and incident characteristics.

## Architecture

```text
Auto insurance claims CSV
          |
          v
Databricks / PySpark ingestion
          |
          v
BRONZE — insurance.bronze.raw_claims
Raw Delta table + ingestion metadata
          |
          v
SILVER — dbt staging (stg_claims)
Type casting · column normalization · categorical cleaning
          |
          v
GOLD — dbt analytics marts
Fact and dimension models for reporting
          |
          v
Tableau Public — interactive claims dashboard

GitHub Actions → Python/YAML linting → dbt build & tests
```

## Technology Stack

| Area | Technologies |
| --- | --- |
| Data platform | Databricks, Unity Catalog, Delta Lake |
| Ingestion | Python, PySpark |
| Transformations | dbt Core, dbt-databricks, SQL |
| Modeling | Medallion architecture, dimensional modeling |
| Data quality | dbt generic tests and relationship checks |
| CI | GitHub Actions, Ruff, YAMLlint |
| Environment management | uv, Python 3.13 |
| Visualization | Tableau Public |

## Pipeline Walkthrough

### 1. Bronze — raw ingestion

A PySpark ingestion notebook loads the source CSV into a Databricks Delta table, retaining the original claim fields and adding `_ingested_at` and `_source_file` for traceability.

**Source relation:** `insurance.bronze.raw_claims`

### 2. Silver — cleaning and standardization

The `stg_claims` dbt model reads the Bronze source and prepares it for downstream analysis. Transformations include:

- Casting dates, amounts, ages, and counts to appropriate types.
- Standardizing field names such as `policy_deductable` → `policy_deductible`.
- Handling source columns containing hyphens, such as `capital-gains` and `capital-loss`.
- Trimming categorical values and normalizing state abbreviations.
- Converting the `fraud_reported` Y/N flag into a boolean `is_fraud` field.
- Preserving ingestion metadata for traceability.

### 3. Gold — analytics-ready marts

The dbt mart layer organizes cleaned claim records into fact and dimension models, making it easier to explore claims alongside policyholders, vehicles, and incident attributes. Model definitions and their dependencies are documented through dbt's lineage graph.

### 4. Analytics — Tableau

The Tableau dashboard provides an interactive interface for exploring the insurance claims dataset.

**[Open the live Tableau dashboard](https://public.tableau.com/app/profile/vanilton.paulo/viz/InsuranceClaimsAnalysis_17933994207990/InsuranceClaimsAnalysis?publish=yes)**

![Tableau Dashboard Screenshot](docs/dashboard-screenshot.png)

## dbt Data Lineage

The lineage graph shows how source data feeds staging transformations and downstream marts, making dependencies easier to understand and changes easier to assess.

![dbt Lineage Graph](docs/dbt-lineage.png)

## Data Quality & Continuous Integration

The project uses dbt tests to validate important assumptions about the transformed data, including non-null fields, accepted categorical values, uniqueness where appropriate, and relationships between fact and dimension models.

The GitHub Actions workflow runs on pushes and pull requests targeting `main` and can also be triggered manually. Its jobs cover:

1. **Code quality:** Python linting and formatting with Ruff, plus YAMLlint checks.
2. **Databricks integration:** Dependency installation, connection validation, and `dbt build --target ci` to build models and execute configured tests.
3. **Artifacts:** Upload of dbt run results and the manifest for troubleshooting.

The database-connected job is restricted to trusted pull requests to avoid exposing credentials to untrusted contributions.

## Project Structure

```text
.
├── .github/workflows/dbt-ci.yml
├── insurance_claims_pipeline/
│   ├── dbt_project.yml
│   ├── profiles.yml                 # CI profile; uses environment variables
│   ├── models/
│   │   ├── staging/
│   │   │   ├── _sources.yml
│   │   │   ├── _stg_schema.yml
│   │   │   └── stg_claims.sql
│   │   └── marts/
│   ├── macros/
│   ├── seeds/
│   ├── snapshots/
│   └── tests/
├── docs/
│   ├── dashboard-screenshot.png
│   └── dbt-lineage.png
├── pyproject.toml
└── uv.lock
```

> The `docs/` images must exist at the repository root for the previews above to render. The tree is a guide to the intended layout; check the repository for the latest files.

## Run Locally

**Prerequisites:** Python 3.13, [uv](https://docs.astral.sh/uv/), a Databricks workspace, and access to a SQL warehouse and the `insurance` catalog.

```bash
# Clone the repository
git clone https://github.com/vaniltonpaulo/insurance-claim-pipeline.git
cd insurance-claim-pipeline

# Install locked Python dependencies
uv sync --locked

# Move into the dbt project
cd insurance_claims_pipeline
```

For local development, configure `~/.dbt/profiles.yml` with your Databricks host, SQL warehouse HTTP path, catalog, schema, and authentication. **Never commit a personal access token.** If using the repository's CI profile, provide `DBT_DATABRICKS_HOST`, `DBT_DATABRICKS_HTTP_PATH`, and `DBT_DATABRICKS_TOKEN` through environment variables.

```bash
# Verify connection and install dbt packages
uv run --project .. dbt debug
uv run --project .. dbt deps

# Build models and run tests
uv run --project .. dbt build

# Optional: generate documentation and inspect model lineage
uv run --project .. dbt docs generate
uv run --project .. dbt docs serve
```

The raw Bronze table must be populated before running downstream models. CI uses `--target ci` and its own environment-based profile.

## Key Skills Demonstrated

- Designing a Bronze–Silver–Gold analytics pipeline on Databricks.
- Building reusable SQL transformations and dimensional marts with dbt.
- Implementing data quality checks and documenting model dependencies.
- Managing Python dependencies reproducibly with uv.
- Running automated linting and database-backed tests in GitHub Actions.
- Publishing a shareable Tableau analytics dashboard.

## Project Inspiration & Credits

Built as a hands-on implementation inspired by the **[NextWork — Insurance Claims Pipeline with dbt](https://nextwork.ai/projects/dab22c1a-69b1-4d4f-92af-9199696e74de)** learning project. The linked tutorial provides the original project brief and implementation exercises.
