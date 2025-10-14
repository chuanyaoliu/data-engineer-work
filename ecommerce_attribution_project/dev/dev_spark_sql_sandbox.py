import argparse
import os
from typing import List, Optional

from pyspark.sql import SparkSession, DataFrame


def read_sql_file(path: str) -> List[str]:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    # Naive splitter by semicolon; adequate for test SQL in this repo
    stmts = [s.strip() for s in content.split(";") if s.strip()]
    return stmts


def run_sql_file(spark: SparkSession, path: str) -> None:
    for stmt in read_sql_file(path):
        spark.sql(stmt)


def run_target_sql(spark: SparkSession, path: str, final_view: Optional[str]) -> DataFrame:
    sql_text = open(path, "r", encoding="utf-8").read()
    stmts = [s.strip() for s in sql_text.split(";") if s.strip()]
    last_df: Optional[DataFrame] = None
    for i, stmt in enumerate(stmts):
        # For intermediate DDL/insert/create statements result is empty; we capture last select
        if stmt.lower().lstrip().startswith("select"):
            last_df = spark.sql(stmt)
        else:
            spark.sql(stmt)
    if final_view:
        return spark.table(final_view)
    if last_df is None:
        # Fallback: if no SELECT found, try reading the final_view or raise
        raise ValueError("No SELECT statement found in target SQL and no --final-view provided")
    return last_df


def main() -> None:
    parser = argparse.ArgumentParser(description="Local Spark SQL sandbox: load mock/test SQL, then execute a target SQL and optionally assert row count.")
    parser.add_argument("--mock", default="ecommerce_attribution_project/sql/test/mock_data_generation.sql", help="Path to SQL that prepares mock data (tables/views).")
    parser.add_argument("--prepare", default="", help="Optional SQL file to prepare schemas or intermediate views before target (e.g., ODS/DWD build).")
    parser.add_argument("--target", required=True, help="Target SQL file to run and show result. Supports multiple statements.")
    parser.add_argument("--final-view", dest="final_view", default=None, help="Optional: name of the final view/table to display when target contains only DDL/INSERT/CREATE statements.")
    parser.add_argument("--assert-row-count", type=int, default=-1, help="If >=0, assert the resulting DataFrame has this row count.")
    parser.add_argument("--show", type=int, default=50, help="Show top N rows from the target result.")
    args = parser.parse_args()

    spark = (
        SparkSession.builder
        .master("local[2]")
        .appName("sql-sandbox")
        .config("spark.sql.shuffle.partitions", "8")
        .getOrCreate()
    )

    try:
        if args.mock and os.path.exists(args.mock):
            run_sql_file(spark, args.mock)

        if args.prepare:
            if os.path.exists(args.prepare):
                run_sql_file(spark, args.prepare)
            else:
                raise FileNotFoundError(f"Prepare SQL not found: {args.prepare}")

        if not os.path.exists(args.target):
            raise FileNotFoundError(f"Target SQL not found: {args.target}")

        df = run_target_sql(spark, args.target, args.final_view)
        df.show(args.show, truncate=False)

        if args.assert_row_count >= 0:
            cnt = df.count()
            assert cnt == args.assert_row_count, f"Row count mismatch: expected {args.assert_row_count}, got {cnt}"

        print("OK")
    finally:
        spark.stop()


if __name__ == "__main__":
    main()


