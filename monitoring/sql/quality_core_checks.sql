-- 主键唯一性、空值、总行数
SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  COUNT(DISTINCT order_id) AS uniq_order_id,
  COUNT(1) AS rows
FROM dwh.dwd.orders_dwd
WHERE dt='${today}';


