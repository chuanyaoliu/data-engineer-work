param(
  [string]$Target = "ecommerce_attribution_project/sql/etl/dws_etl.sql",
  [string]$Mock = "ecommerce_attribution_project/sql/test/mock_data_generation.sql",
  [string]$Prepare = "",
  [string]$FinalView = "",
  [int]$AssertRowCount = -1,
  [int]$Show = 50
)

Write-Host "Running Spark SQL sandbox..." -ForegroundColor Cyan
if ($FinalView -ne "") {
  if ($Prepare -ne "") {
    python "ecommerce_attribution_project/dev/dev_spark_sql_sandbox.py" --target $Target --mock $Mock --prepare $Prepare --final-view $FinalView --assert-row-count $AssertRowCount --show $Show
  } else {
    python "ecommerce_attribution_project/dev/dev_spark_sql_sandbox.py" --target $Target --mock $Mock --final-view $FinalView --assert-row-count $AssertRowCount --show $Show
  }
} else {
  if ($Prepare -ne "") {
    python "ecommerce_attribution_project/dev/dev_spark_sql_sandbox.py" --target $Target --mock $Mock --prepare $Prepare --assert-row-count $AssertRowCount --show $Show
  } else {
    python "ecommerce_attribution_project/dev/dev_spark_sql_sandbox.py" --target $Target --mock $Mock --assert-row-count $AssertRowCount --show $Show
  }
}

if ($LASTEXITCODE -ne 0) {
  Write-Host "Sandbox run failed." -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host "Sandbox run succeeded." -ForegroundColor Green

