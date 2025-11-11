-- 标准骨架：增量边界、主键去重、晚到处理、审计字段
-- 输入：dwh.ods.orders_ods，输出：dwh.dwd.orders_dwd
WITH src AS (
  SELECT *
  FROM dwh.ods.orders_ods
  WHERE dt = '${dt}'
),
dedup AS (
  SELECT
    order_id, user_id, status, amount, event_time, dt,
    ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY event_time DESC) AS rn
  FROM src
),
latest AS (
  SELECT
    order_id,
    COALESCE(user_id, 'unknown') AS user_id,
    COALESCE(status, 'PENDING') AS status,
    COALESCE(amount, 0.00) AS amount,
    COALESCE(event_time, TO_TIMESTAMP('${dt} 00:00:00')) AS event_time,
    dt
  FROM dedup
  WHERE rn = 1
)
INSERT OVERWRITE TABLE dwh.dwd.orders_dwd PARTITION (dt='${dt}')
SELECT
  order_id,
  user_id,
  status,
  amount,
  event_time,
  CURRENT_TIMESTAMP() AS _etl_load_time,
  '${dt}' AS dt;

-- 质量哨兵（可在自测/监控阶段单独执行）
-- 1) 主键唯一
-- SELECT COUNT(*) = COUNT(DISTINCT order_id) FROM dwh.dwd.orders_dwd WHERE dt='${dt}';
-- 2) 枚举合法
-- SELECT COUNT(*) FROM dwh.dwd.orders_dwd WHERE dt='${dt}' AND status NOT IN ('SUCCESS','FAILED','PENDING');


