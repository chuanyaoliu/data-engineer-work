-- 检查当日分区是否产出
SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS partition_ready
FROM dwh.dwd.orders_dwd
WHERE dt = '${today}';


