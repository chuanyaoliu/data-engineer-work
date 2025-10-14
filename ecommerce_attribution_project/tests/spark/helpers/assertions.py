from typing import Iterable, List
from pyspark.sql import DataFrame, functions as F


def assert_rowcount_between(df: DataFrame, min_count: int, max_count: int) -> None:
    cnt = df.count()
    assert min_count <= cnt <= max_count, f"Row count {cnt} not in [{min_count}, {max_count}]"


def assert_no_nulls(df: DataFrame, columns: Iterable[str]) -> None:
    for c in columns:
        nulls = df.filter(F.col(c).isNull()).limit(1).count()
        assert nulls == 0, f"Column {c} contains NULLs"


def assert_unique_key(df: DataFrame, columns: List[str]) -> None:
    dup = df.groupBy(*columns).count().filter(F.col("count") > 1).limit(1).count()
    assert dup == 0, f"Duplicate keys found for {columns}"


def assert_values_in_set(df: DataFrame, column: str, allowed: Iterable) -> None:
    invalid = df.select(column).distinct().filter(~F.col(column).isin(list(allowed))).limit(1).count()
    assert invalid == 0, f"Column {column} contains values outside allowed set"


