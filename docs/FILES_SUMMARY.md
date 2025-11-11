# Files Summary (26 items)

- context/catalog/README.md: Physical catalog tree purpose and fields; used to drive GE rules and contracts.
- context/catalog/sample_catalog.yaml: Example catalog with ODS/DWD tables, PK/partition/columns and sensitivity.
- context/subject/README.md: Semantic subject tree purpose; MetricFlow-style metrics and reference SQL notes.
- context/subject/ecommerce/metrics.yaml: Ecommerce orders subject; metrics, dimensions, rules, PK/event_time/partition.
- context/subject/ecommerce/reference_sql/sample_order_metrics.sql: Reference SQL for daily order metrics (cnt, amount).
- context/success_stories/README.md: How to record success/failure stories for context and evaluation.
- context/success_stories/samples.md: Example incident: GMV deviation, root cause and fix summary.
- agents/subagents/ecommerce/config.yaml: Scoped subagent config binding catalog/subject paths and allowed tools.
- agents/subagents/ecommerce/prompts.md: Subagent system guidance: prefer recall/modify, show explain and optimizations.
- requirements/templates/requirement_intake.md: Requirement intake template covering inputs/outputs/SLA/quality/depends.
- requirements/templates/data_contract.json: JSON Schema for inputs/outputs/SLA; basis for context/rules generation.
- requirements/transformers/gen_context_from_requirement.py: Placeholder generator printing planned outputs from contract.
- sql/reference/README.md: Purpose of high-value reference SQL directory for recall and small-step edits.
- sql/etl/dwd_etl.sql: Standard Spark SQL skeleton: incremental boundary, dedup, late-arrival, audit fields.
- sql/tests/regression/compare_rowcount.sql: Baseline vs current rowcount regression comparison.
- sql/tests/regression/compare_pk_unique.sql: Baseline vs current PK uniqueness and row count comparison.
- tests/pyspark/local_selftest_example.py: Minimal local PySpark self-test with sample data and assertions.
- tests/expectations/ge_basic.yml: GE basic rules: rowcount min, PK not null/unique, status enum regex.
- tests/expectations/ge_catalog_expectations.yml: GE rules derived from catalog: not-null, unique, enum status.
- monitoring/sql/sla_partition_ready.sql: Partition readiness check for daily SLA.
- monitoring/sql/quality_core_checks.sql: Core quality snapshot: nulls, PK cardinality, total rows.
- monitoring/sql/distribution_watch.sql: Rolling distribution watch with Z-scores for rows and GMV.
- workflows/cli_recipes.md: CLI workflow: recall → execute/explain → observe → reflect → record.
- workflows/runbook.md: Operational runbook and self-healing suggestions for common issues.
- docs/README.md: Top-level guide to use the four stages end-to-end with pointers.
- docs/ADRs/adr-0001-context-engine.md: Decision record adopting dual-tree Context Engine and subagent delivery.\n

