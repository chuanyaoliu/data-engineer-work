-- 分布与波动监控（示例：行数与 GMV 的环/同比及 Z-Score）
WITH cur AS (
  SELECT dt,
         COUNT(*) AS rows,
         SUM(amount) AS gmvv
  FROM dwh.dwd.orders_dwd
  WHERE dt BETWEEN DATE_SUB('${today}', 7) AND '${today}'
  GROUP BY dt
),
stats AS (
  SELECT
    AVG(rows) AS avg_rows, STDDEV_POP(rows) AS sd_rows,
    AVG(gmvv) AS avg_gmvv, STDDEV_POP(gmvv) AS sd_gmvv
  FROM cur
)
SELECT
  c.dt,
  c.rows,
  c.gmvv,
  (c.rows - s.avg_rows) / NULLIF(s.sd_rows, 0) AS z_rows,
  (c.gmvv - s.avg_gmvv) / NULLIF(s.sd_gmvv, 0) AS z_gmvv
FROM cur c CROSS JOIN stats s
ORDER BY c.dt;


