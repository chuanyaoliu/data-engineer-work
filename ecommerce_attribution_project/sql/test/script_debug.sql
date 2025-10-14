-- 脚本调试与验证脚本
-- 描述: 验证ETL脚本执行结果和数据质量
-- 执行时间: 测试环境

-- =============================================
-- 1. 语法检查
-- =============================================
-- 检查DDL语句语法
EXPLAIN CREATE TABLE test_syntax_check (
    id INT,
    name STRING
);

-- =============================================
-- 2. 数据量验证
-- =============================================
-- 检查各层数据量
SELECT 'ODS层点击日志' as table_name, COUNT(*) as record_count FROM ods_ecommerce_click_log WHERE dt='2024-01-01'
UNION ALL
SELECT 'ODS层浏览日志' as table_name, COUNT(*) as record_count FROM ods_ecommerce_page_view_log WHERE dt='2024-01-01'
UNION ALL
SELECT 'DWD层行为路径' as table_name, COUNT(*) as record_count FROM dwd_ecommerce_user_behavior_path WHERE dt='2024-01-01'
UNION ALL
SELECT 'DWS层流量归因' as table_name, COUNT(*) as record_count FROM dws_ecommerce_product_detail_attribution WHERE dt='2024-01-01'
UNION ALL
SELECT 'ADS层汇总数据' as table_name, COUNT(*) as record_count FROM ads_ecommerce_attribution_summary WHERE dt='2024-01-01';

-- =============================================
-- 3. 数据质量检查
-- =============================================
-- 检查关键字段空值情况
SELECT 
    'ODS点击日志' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) as null_ts_count
FROM ods_ecommerce_click_log 
WHERE dt='2024-01-01'

UNION ALL

SELECT 
    'ODS浏览日志' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) as null_ts_count
FROM ods_ecommerce_page_view_log 
WHERE dt='2024-01-01'

UNION ALL

SELECT 
    'DWD行为路径' as table_name,
    COUNT(*) as total_count,
    SUM(CASE WHEN uid IS NULL THEN 1 ELSE 0 END) as null_uid_count,
    SUM(CASE WHEN sid IS NULL THEN 1 ELSE 0 END) as null_sid_count,
    SUM(CASE WHEN ts IS NULL THEN 1 ELSE 0 END) as null_ts_count
FROM dwd_ecommerce_user_behavior_path 
WHERE dt='2024-01-01';

-- =============================================
-- 4. 商详页访问数据验证
-- =============================================
-- 检查商详页访问统计
SELECT 
    '商详页访问统计' as metric_name,
    COUNT(*) as total_visits,
    COUNT(DISTINCT uid) as unique_users,
    COUNT(DISTINCT product_id) as unique_products,
    ROUND(AVG(path_length), 2) as avg_path_length,
    ROUND(AVG(conversion_time), 2) as avg_conversion_time
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

-- =============================================
-- 5. 入口渠道分布验证
-- =============================================
-- 检查入口渠道分布
SELECT 
    entry_channel,
    entry_page_type,
    COUNT(*) as visit_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01'
GROUP BY entry_channel, entry_page_type
ORDER BY visit_count DESC;

-- =============================================
-- 6. 路径长度分布验证
-- =============================================
-- 检查路径长度分布
SELECT 
    path_length,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01'
GROUP BY path_length
ORDER BY path_length;

-- =============================================
-- 7. 归因权重验证
-- =============================================
-- 检查归因权重分布
SELECT 
    CASE 
        WHEN attribution_weight = 1.0 THEN '1.0 (直接访问)'
        WHEN attribution_weight = 0.8 THEN '0.8 (短路径)'
        WHEN attribution_weight = 0.6 THEN '0.6 (中路径)'
        WHEN attribution_weight = 0.4 THEN '0.4 (长路径)'
        ELSE '其他'
    END as weight_category,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01'
GROUP BY 
    CASE 
        WHEN attribution_weight = 1.0 THEN '1.0 (直接访问)'
        WHEN attribution_weight = 0.8 THEN '0.8 (短路径)'
        WHEN attribution_weight = 0.6 THEN '0.6 (中路径)'
        WHEN attribution_weight = 0.4 THEN '0.4 (长路径)'
        ELSE '其他'
    END
ORDER BY weight_category;

-- =============================================
-- 8. 设备类型分布验证
-- =============================================
-- 检查设备类型分布
SELECT 
    device_type,
    platform,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01'
GROUP BY device_type, platform
ORDER BY count DESC;

-- =============================================
-- 9. 时间序列验证
-- =============================================
-- 检查时间序列连续性
SELECT 
    '时间范围检查' as check_type,
    MIN(entry_ts) as min_entry_ts,
    MAX(entry_ts) as max_entry_ts,
    MIN(product_detail_ts) as min_product_detail_ts,
    MAX(product_detail_ts) as max_product_detail_ts
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

-- =============================================
-- 10. 数据一致性验证
-- =============================================
-- 检查数据一致性
SELECT 
    '数据一致性检查' as check_type,
    COUNT(*) as total_records,
    COUNT(DISTINCT CONCAT(uid, '_', sid)) as unique_sessions,
    SUM(CASE WHEN product_detail_ts < entry_ts THEN 1 ELSE 0 END) as invalid_time_sequence
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';
