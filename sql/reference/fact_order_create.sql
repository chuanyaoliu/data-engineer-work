-- dwd.fact_order DDL (Spark SQL)
CREATE DATABASE IF NOT EXISTS dwd;

CREATE TABLE IF NOT EXISTS dwd.fact_order (
  order_id      BIGINT,
  user_id       BIGINT,
  product_id    BIGINT,
  amount        DECIMAL(18,2),
  quantity      INT,
  order_status  STRING,
  order_time    TIMESTAMP,
  channel       STRING,
  region        STRING
)
USING PARQUET
PARTITIONED BY (dt STRING)
TBLPROPERTIES (
  'delta.minReaderVersion'='1'
);
