-- Load mock CSV into dwd.fact_order (Spark SQL)
-- Adjust the path to your workspace root if needed
CREATE OR REPLACE TEMP VIEW fact_order_csv
USING csv
OPTIONS (
  path 'data/mock/fact_order.csv',
  header 'true',
  inferSchema 'true',
  multiLine 'false',
  timestampFormat 'yyyy-MM-dd\'T\'HH:mm:ss'
);

INSERT OVERWRITE TABLE dwd.fact_order PARTITION (dt)
SELECT
  CAST(order_id AS BIGINT)        AS order_id,
  CAST(user_id AS BIGINT)         AS user_id,
  CAST(product_id AS BIGINT)      AS product_id,
  CAST(amount AS DECIMAL(18,2))   AS amount,
  CAST(quantity AS INT)           AS quantity,
  CAST(order_status AS STRING)    AS order_status,
  CAST(order_time AS TIMESTAMP)   AS order_time,
  CAST(channel AS STRING)         AS channel,
  CAST(region AS STRING)          AS region,
  CAST(dt AS STRING)              AS dt
FROM fact_order_csv;
