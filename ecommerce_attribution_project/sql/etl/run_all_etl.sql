-- 完整ETL执行脚本
-- 描述: 按顺序执行所有ETL步骤
-- 执行时间: 每日凌晨2-6点

-- 设置Hive参数
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=10000;
SET hive.exec.max.dynamic.partitions.pernode=10000;

-- 设置Spark参数
SET spark.sql.adaptive.enabled=true;
SET spark.sql.adaptive.coalescePartitions.enabled=true;
SET spark.sql.adaptive.skewJoin.enabled=true;

-- =============================================
-- 步骤1: 执行ODS层ETL
-- =============================================
-- 执行时间: 02:00-02:30
SOURCE ecommerce_attribution_project/sql/etl/ods_etl.sql;

-- =============================================
-- 步骤2: 执行DWD层ETL
-- =============================================
-- 执行时间: 03:00-03:30
SOURCE ecommerce_attribution_project/sql/etl/dwd_etl.sql;

-- =============================================
-- 步骤3: 执行DWS层ETL
-- =============================================
-- 执行时间: 04:00-04:30
SOURCE ecommerce_attribution_project/sql/etl/dws_etl.sql;

-- =============================================
-- 步骤4: 执行ADS层ETL
-- =============================================
-- 执行时间: 05:00-05:30
SOURCE ecommerce_attribution_project/sql/etl/ads_etl.sql;

-- =============================================
-- 数据质量检查
-- =============================================
-- 检查各层数据量
SELECT 'ODS层点击日志' as table_name, COUNT(*) as record_count FROM ods_ecommerce_click_log WHERE dt='${hiveconf:dt}'
UNION ALL
SELECT 'ODS层浏览日志' as table_name, COUNT(*) as record_count FROM ods_ecommerce_page_view_log WHERE dt='${hiveconf:dt}'
UNION ALL
SELECT 'DWD层行为路径' as table_name, COUNT(*) as record_count FROM dwd_ecommerce_user_behavior_path WHERE dt='${hiveconf:dt}'
UNION ALL
SELECT 'DWS层流量归因' as table_name, COUNT(*) as record_count FROM dws_ecommerce_product_detail_attribution WHERE dt='${hiveconf:dt}'
UNION ALL
SELECT 'ADS层汇总数据' as table_name, COUNT(*) as record_count FROM ads_ecommerce_attribution_summary WHERE dt='${hiveconf:dt}';

-- 检查商详页访问数据
SELECT 
    '商详页访问统计' as metric_name,
    COUNT(*) as total_visits,
    COUNT(DISTINCT uid) as unique_users,
    COUNT(DISTINCT product_id) as unique_products,
    ROUND(AVG(path_length), 2) as avg_path_length
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='${hiveconf:dt}';

-- 检查入口渠道分布
SELECT 
    entry_channel,
    entry_page_type,
    COUNT(*) as visit_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='${hiveconf:dt}'
GROUP BY entry_channel, entry_page_type
ORDER BY visit_count DESC;
