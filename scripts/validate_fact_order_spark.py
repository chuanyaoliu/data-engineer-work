from pyspark.sql import SparkSession
from pyspark.sql.functions import col, regexp_extract

spark = SparkSession.builder.appName("fact_order_validation").getOrCreate()

df = spark.table("dwd.fact_order")

errors = []

# order_id not null
cnt_null_order_id = df.filter(col("order_id").isNull()).count()
if cnt_null_order_id > 0:
    errors.append(f"order_id has {cnt_null_order_id} nulls")

# order_id unique
total = df.count()
unique = df.select("order_id").distinct().count()
if unique != total:
    errors.append(f"order_id not unique: total={total}, distinct={unique}")

# dt not null and format yyyy-MM-dd
cnt_null_dt = df.filter(col("dt").isNull()).count()
if cnt_null_dt > 0:
    errors.append(f"dt has {cnt_null_dt} nulls")

fmt_mismatch = df.withColumn("_ok", regexp_extract(col("dt"), r"^\\d{4}-\\d{2}-\\d{2}$", 0)) \
               .filter(col("_ok") == "").count()
if fmt_mismatch > 0:
    errors.append(f"dt format mismatch rows={fmt_mismatch}")

# quantity >= 0
qty_neg = df.filter(col("quantity") < 0).count()
if qty_neg > 0:
    errors.append(f"quantity negative rows={qty_neg}")

# amount >= 0 (allow mostly >=0: 95%)
amt_neg = df.filter(col("amount") < 0).count()
if amt_neg / max(total, 1) > 0.05:
    errors.append(f"amount negative ratio>{0.05}: neg={amt_neg}, total={total}")

# order_status in set
allowed = {"paid", "cancelled", "refunded"}
bad_status = df.filter(~col("order_status").isin(list(allowed))).count()
if bad_status > 0:
    errors.append(f"order_status invalid rows={bad_status}")

if errors:
    print("Validation FAILED:")
    for e in errors:
        print("- ", e)
    spark.stop()
    exit(1)
else:
    print("Validation PASSED.")
    spark.stop()
    exit(0)
