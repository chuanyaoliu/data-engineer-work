import os
import pytest
from pyspark.sql import SparkSession


@pytest.fixture(scope="session")
def spark_session():
    spark = (
        SparkSession.builder
        .master("local[2]")
        .appName("ads-sql-tests")
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


def test_ads_sql_executes(spark_session: SparkSession):
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
    mock_sql = os.path.join(repo_root, "ecommerce_attribution_project", "sql", "test", "mock_data_generation.sql")
    target_sql = os.path.join(repo_root, "ecommerce_attribution_project", "sql", "etl", "ads_etl.sql")

    if os.path.exists(mock_sql):
        _run_sql_file(spark_session, mock_sql)

    with open(target_sql, "r", encoding="utf-8") as f:
        df = spark_session.sql(f.read())

    # 基础断言：可根据业务口径改为断言主键唯一、指标范围等
    assert df is not None
    _ = df.count()


