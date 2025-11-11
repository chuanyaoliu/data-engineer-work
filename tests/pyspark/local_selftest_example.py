from pyspark.sql import SparkSession, functions as F

spark = (SparkSession.builder
         .appName("local-sql-test")
         .master("local[*]")
         .config("spark.sql.shuffle.partitions", "4")
         .getOrCreate())

# 样例数据（可按需扩充）
data = [
    ("o1", "u1", "SUCCESS", 10.0, "2025-11-01 10:00:00", "2025-11-01"),
    ("o1", "u1", "SUCCESS", 10.0, "2025-11-01 12:00:00", "2025-11-01"),  # later version
    ("o2", "u2", None, 20.0, "2025-11-01 09:00:00", "2025-11-01"),
]
df = spark.createDataFrame(data, "order_id string, user_id string, status string, amount double, event_time string, dt string") \
         .withColumn("event_time", F.to_timestamp("event_time"))
df.createOrReplaceTempView("dwh_ods_orders_ods")
spark.sql("CREATE OR REPLACE TEMP VIEW dwh__ods__orders_ods AS SELECT * FROM dwh_ods_orders_ods")  # alias

# 将骨架 SQL 适配为本地表名（示意）
sql = """
WITH src AS (
  SELECT * FROM dwh__ods__orders_ods WHERE dt = '2025-11-01'
),
dedup AS (
  SELECT order_id, user_id, status, amount, event_time, dt,
         ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY event_time DESC) AS rn
  FROM src
),
latest AS (
  SELECT
    order_id,
    COALESCE(user_id, 'unknown') AS user_id,
    COALESCE(status, 'PENDING') AS status,
    COALESCE(amount, 0.00) AS amount,
    COALESCE(event_time, TO_TIMESTAMP('2025-11-01 00:00:00')) AS event_time,
    dt
  FROM dedup WHERE rn = 1
)
SELECT order_id, user_id, status, amount, event_time, current_timestamp() AS _etl_load_time, '2025-11-01' AS dt
FROM latest
"""
res = spark.sql(sql)

# 断言
assert res.count() == 2
assert res.select(F.countDistinct("order_id")).first()[0] == 2
assert res.filter(F.col("status").isin("SUCCESS", "FAILED", "PENDING")).count() == res.count()

# 指标快照
res.groupBy().agg(
    F.count("*").alias("rows"),
    F.countDistinct("order_id").alias("uniq_order_id"),
    F.sum("amount").alias("sum_amount")
).show(truncate=False)

print("Local self-test passed.")


