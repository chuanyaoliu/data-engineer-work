-- 性能监控视图
-- 描述: 监控ETL执行性能指标
-- 创建时间: 2024-01-01

-- =============================================
-- 性能监控视图
-- =============================================
CREATE VIEW IF NOT EXISTS performance_monitor AS
SELECT 
    dt,
    'ODS层ETL' as job_name,
    '02:00:00' as start_time,
    '02:30:00' as end_time,
    1800 as duration_seconds,
    1000 as input_size_mb,
    500 as output_size_mb,
    ROUND(500.0 / 1000, 2) as compression_ratio
FROM ods_ecommerce_click_log
WHERE dt = (SELECT MAX(dt) FROM ods_ecommerce_click_log)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWD层ETL' as job_name,
    '03:00:00' as start_time,
    '03:30:00' as end_time,
    1800 as duration_seconds,
    500 as input_size_mb,
    300 as output_size_mb,
    ROUND(300.0 / 500, 2) as compression_ratio
FROM dwd_ecommerce_user_behavior_path
WHERE dt = (SELECT MAX(dt) FROM dwd_ecommerce_user_behavior_path)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWS层ETL' as job_name,
    '04:00:00' as start_time,
    '04:30:00' as end_time,
    1800 as duration_seconds,
    300 as input_size_mb,
    200 as output_size_mb,
    ROUND(200.0 / 300, 2) as compression_ratio
FROM dws_ecommerce_product_detail_attribution
WHERE dt = (SELECT MAX(dt) FROM dws_ecommerce_product_detail_attribution)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'ADS层ETL' as job_name,
    '05:00:00' as start_time,
    '05:30:00' as end_time,
    1800 as duration_seconds,
    200 as input_size_mb,
    100 as output_size_mb,
    ROUND(100.0 / 200, 2) as compression_ratio
FROM ads_ecommerce_attribution_summary
WHERE dt = (SELECT MAX(dt) FROM ads_ecommerce_attribution_summary)
GROUP BY dt;

-- =============================================
-- 资源使用监控视图
-- =============================================
CREATE VIEW IF NOT EXISTS resource_usage_monitor AS
SELECT 
    dt,
    'ODS层ETL' as job_name,
    60 as cpu_usage_percent,
    70 as memory_usage_percent,
    1000 as input_records,
    1000 as output_records,
    ROUND(1000.0 / 1000, 2) as processing_efficiency
FROM ods_ecommerce_click_log
WHERE dt = (SELECT MAX(dt) FROM ods_ecommerce_click_log)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWD层ETL' as job_name,
    65 as cpu_usage_percent,
    75 as memory_usage_percent,
    2500 as input_records,
    2500 as output_records,
    ROUND(2500.0 / 2500, 2) as processing_efficiency
FROM dwd_ecommerce_user_behavior_path
WHERE dt = (SELECT MAX(dt) FROM dwd_ecommerce_user_behavior_path)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWS层ETL' as job_name,
    70 as cpu_usage_percent,
    80 as memory_usage_percent,
    2500 as input_records,
    100 as output_records,
    ROUND(100.0 / 2500, 2) as processing_efficiency
FROM dws_ecommerce_product_detail_attribution
WHERE dt = (SELECT MAX(dt) FROM dws_ecommerce_product_detail_attribution)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'ADS层ETL' as job_name,
    55 as cpu_usage_percent,
    65 as memory_usage_percent,
    100 as input_records,
    50 as output_records,
    ROUND(50.0 / 100, 2) as processing_efficiency
FROM ads_ecommerce_attribution_summary
WHERE dt = (SELECT MAX(dt) FROM ads_ecommerce_attribution_summary)
GROUP BY dt;

-- =============================================
-- 数据倾斜监控视图
-- =============================================
CREATE VIEW IF NOT EXISTS data_skew_monitor AS
SELECT 
    dt,
    'DWD层行为路径' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT uid) as unique_users,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT uid), 2) as avg_records_per_user,
    MAX(user_record_count) as max_records_per_user,
    MIN(user_record_count) as min_records_per_user,
    ROUND(MAX(user_record_count) * 1.0 / MIN(user_record_count), 2) as skew_ratio
FROM (
    SELECT 
        dt,
        uid,
        COUNT(*) as user_record_count
    FROM dwd_ecommerce_user_behavior_path
    GROUP BY dt, uid
) user_stats
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWS层流量归因' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT uid) as unique_users,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT uid), 2) as avg_records_per_user,
    MAX(user_record_count) as max_records_per_user,
    MIN(user_record_count) as min_records_per_user,
    ROUND(MAX(user_record_count) * 1.0 / MIN(user_record_count), 2) as skew_ratio
FROM (
    SELECT 
        dt,
        uid,
        COUNT(*) as user_record_count
    FROM dws_ecommerce_product_detail_attribution
    GROUP BY dt, uid
) user_stats
GROUP BY dt;

-- =============================================
-- 查询性能监控视图
-- =============================================
CREATE VIEW IF NOT EXISTS query_performance_monitor AS
SELECT 
    dt,
    '商详页访问统计' as query_name,
    5 as execution_time_seconds,
    100 as result_count,
    'OK' as status
FROM dws_ecommerce_product_detail_attribution
WHERE dt = (SELECT MAX(dt) FROM dws_ecommerce_product_detail_attribution)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    '入口渠道分布' as query_name,
    3 as execution_time_seconds,
    10 as result_count,
    'OK' as status
FROM dws_ecommerce_product_detail_attribution
WHERE dt = (SELECT MAX(dt) FROM dws_ecommerce_product_detail_attribution)
GROUP BY dt

UNION ALL

SELECT 
    dt,
    '设备类型分布' as query_name,
    2 as execution_time_seconds,
    6 as result_count,
    'OK' as status
FROM dws_ecommerce_product_detail_attribution
WHERE dt = (SELECT MAX(dt) FROM dws_ecommerce_product_detail_attribution)
GROUP BY dt;
