-- 基线 vs 当前：主键唯一性与基数
WITH base AS (
  SELECT COUNT(DISTINCT order_id) AS uniq_pk, COUNT(*) AS rows
  FROM dwh.dwd.orders_dwd WHERE dt='${base_dt}'
),
cur AS (
  SELECT COUNT(DISTINCT order_id) AS uniq_pk, COUNT(*) AS rows
  FROM dwh.dwd.orders_dwd WHERE dt='${cur_dt}'
)
SELECT 'uniq_pk' AS metric, cur.uniq_pk AS cur, base.uniq_pk AS base, (cur.uniq_pk - base.uniq_pk) AS diff
FROM cur CROSS JOIN base
UNION ALL
SELECT 'rows', cur.rows, base.rows, (cur.rows - base.rows) FROM cur CROSS JOIN base;


