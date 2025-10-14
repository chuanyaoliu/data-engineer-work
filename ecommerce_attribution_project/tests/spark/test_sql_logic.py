import os
import pytest

from pyspark.sql import SparkSession
from chispa import assert_df_equality
from ecommerce_attribution_project.tests.spark.helpers.assertions import (
    assert_rowcount_between,
    assert_no_nulls,
    assert_unique_key,
)


@pytest.fixture(scope="session")
def spark_session():
    spark = (
        SparkSession.builder
        .master("local[2]")
        .appName("sql-tests")
        .config("spark.sql.shuffle.partitions", "4")
        .getOrCreate()
    )
    yield spark
    spark.stop()


def _run_sql_file(spark: SparkSession, path: str) -> None:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    stmts = [s.strip() for s in content.split(";") if s.strip()]
    for s in stmts:
        spark.sql(s)


def test_core_logic_rowcount(spark_session: SparkSession):
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
    mock_sql = os.path.join(repo_root, "ecommerce_attribution_project", "sql", "test", "mock_data_generation.sql")
    target_sql = os.path.join(repo_root, "ecommerce_attribution_project", "sql", "etl", "dws_etl.sql")

    if os.path.exists(mock_sql):
        _run_sql_file(spark_session, mock_sql)

    with open(target_sql, "r", encoding="utf-8") as f:
        df = spark_session.sql(f.read())

    # 示例断言：行数范围/主键唯一/关键列非空（按需调整列名）
    assert_rowcount_between(df, 0, 10_000_000)
    # 假设存在 user_id、sku_id 两列作为主键时启用：
    cols = df.columns
    if "user_id" in cols:
        assert_no_nulls(df, ["user_id"])
    if set(["user_id", "sku_id"]).issubset(cols):
        assert_unique_key(df, ["user_id", "sku_id"])


