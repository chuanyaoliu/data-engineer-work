-- Reference: 日粒度订单指标
SELECT
  dt,
  status,
  COUNT(*) AS order_cnt,
  SUM(amount) AS gmvv
FROM dwh.dwd.orders_dwd
WHERE dt BETWEEN '${start_dt}' AND '${end_dt}'
GROUP BY dt, status
ORDER BY dt, status;


