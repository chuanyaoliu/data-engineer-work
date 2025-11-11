param(
  [string]$SparkSql = "spark-sql",
  [string]$SparkSubmit = "spark-submit"
)

Write-Host "[1/3] Creating table dwd.fact_order..."
& $SparkSql -f "sql/reference/fact_order_create.sql"
if ($LASTEXITCODE -ne 0) { Write-Error "DDL failed"; exit 1 }

Write-Host "[2/3] Loading mock data from data/mock/fact_order.csv..."
& $SparkSql -f "sql/reference/fact_order_load.sql"
if ($LASTEXITCODE -ne 0) { Write-Error "Load failed"; exit 1 }

Write-Host "[3/3] Running Spark validation checks..."
& $SparkSubmit "scripts/validate_fact_order_spark.py"
if ($LASTEXITCODE -ne 0) { Write-Error "Validation failed"; exit 2 }

Write-Host "Demo completed successfully."
