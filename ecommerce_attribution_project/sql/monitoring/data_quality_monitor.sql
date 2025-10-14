-- 数据质量监控视图
-- 描述: 监控各层数据质量指标
-- 创建时间: 2024-01-01

-- =============================================
-- 数据质量监控视图
-- =============================================
CREATE VIEW IF NOT EXISTS data_quality_monitor AS
SELECT 
    dt,
    'ODS层点击日志' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) as null_ts_count,
    ROUND(SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_uid_rate,
    ROUND(SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_sid_rate,
    ROUND(SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_ts_rate,
    CASE 
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 THEN 'ERROR'
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 5 THEN 'WARNING'
        ELSE 'OK'
    END as quality_status
FROM ods_ecommerce_click_log
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'ODS层浏览日志' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) as null_ts_count,
    ROUND(SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_uid_rate,
    ROUND(SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_sid_rate,
    ROUND(SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_ts_rate,
    CASE 
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 THEN 'ERROR'
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 5 THEN 'WARNING'
        ELSE 'OK'
    END as quality_status
FROM ods_ecommerce_page_view_log
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWD层行为路径' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) as null_ts_count,
    ROUND(SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_uid_rate,
    ROUND(SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_sid_rate,
    ROUND(SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_ts_rate,
    CASE 
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 THEN 'ERROR'
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 5 THEN 'WARNING'
        ELSE 'OK'
    END as quality_status
FROM dwd_ecommerce_user_behavior_path
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWS层流量归因' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as null_product_id_count,
    ROUND(SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_uid_rate,
    ROUND(SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_sid_rate,
    ROUND(SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_product_id_rate,
    CASE 
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 THEN 'ERROR'
        WHEN SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 5 THEN 'WARNING'
        ELSE 'OK'
    END as quality_status
FROM dws_ecommerce_product_detail_attribution
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'ADS层汇总数据' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as null_product_id_count,
    0 as null_uid_count,
    0 as null_sid_count,
    ROUND(SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_product_id_rate,
    0 as null_uid_rate,
    0 as null_sid_rate,
    CASE 
        WHEN SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 THEN 'ERROR'
        WHEN SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 5 THEN 'WARNING'
        ELSE 'OK'
    END as quality_status
FROM ads_ecommerce_attribution_summary
GROUP BY dt;

-- =============================================
-- 数据量监控视图
-- =============================================
CREATE VIEW IF NOT EXISTS data_volume_monitor AS
SELECT 
    dt,
    'ODS层点击日志' as table_name,
    COUNT(*) as record_count,
    COUNT(DISTINCT uid) as unique_users,
    COUNT(DISTINCT sid) as unique_sessions
FROM ods_ecommerce_click_log
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'ODS层浏览日志' as table_name,
    COUNT(*) as record_count,
    COUNT(DISTINCT uid) as unique_users,
    COUNT(DISTINCT sid) as unique_sessions
FROM ods_ecommerce_page_view_log
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWD层行为路径' as table_name,
    COUNT(*) as record_count,
    COUNT(DISTINCT uid) as unique_users,
    COUNT(DISTINCT sid) as unique_sessions
FROM dwd_ecommerce_user_behavior_path
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'DWS层流量归因' as table_name,
    COUNT(*) as record_count,
    COUNT(DISTINCT uid) as unique_users,
    COUNT(DISTINCT sid) as unique_sessions
FROM dws_ecommerce_product_detail_attribution
GROUP BY dt

UNION ALL

SELECT 
    dt,
    'ADS层汇总数据' as table_name,
    COUNT(*) as record_count,
    COUNT(DISTINCT product_id) as unique_products,
    0 as unique_sessions
FROM ads_ecommerce_attribution_summary
GROUP BY dt;

-- =============================================
-- 业务指标监控视图
-- =============================================
CREATE VIEW IF NOT EXISTS business_metrics_monitor AS
SELECT 
    dt,
    COUNT(*) as total_visits,
    COUNT(DISTINCT uid) as unique_users,
    COUNT(DISTINCT product_id) as unique_products,
    ROUND(AVG(path_length), 2) as avg_path_length,
    ROUND(AVG(conversion_time), 2) as avg_conversion_time,
    ROUND(SUM(CASE WHEN is_direct_visit THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as direct_visit_rate
FROM dws_ecommerce_product_detail_attribution
GROUP BY dt;
