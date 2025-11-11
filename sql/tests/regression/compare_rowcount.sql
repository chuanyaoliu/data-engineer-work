-- 基线 vs 当前：行数对比
WITH base AS (
  SELECT COUNT(*) AS cnt FROM dwh.dwd.orders_dwd WHERE dt='${base_dt}'
),
cur AS (
  SELECT COUNT(*) AS cnt FROM dwh.dwd.orders_dwd WHERE dt='${cur_dt}'
)
SELECT 'row_cnt' AS metric, cur.cnt AS cur, base.cnt AS base, (cur.cnt - base.cnt) AS diff
FROM cur CROSS JOIN base;


