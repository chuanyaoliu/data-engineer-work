-- ADS层ETL脚本
-- 描述: 生成商详页流量归因应用层汇总数据
-- 执行时间: 每日凌晨5点

-- =============================================
-- ADS层商详页流量归因应用汇总ETL
-- =============================================
INSERT OVERWRITE TABLE ads_ecommerce_attribution_summary 
PARTITION (dt='${hiveconf:dt}')
SELECT 
    '${hiveconf:dt}' as stat_date,
    product_id,
    entry_channel,
    entry_page_type,
    COUNT(*) as pv_count,
    COUNT(DISTINCT uid) as uv_count,
    COUNT(DISTINCT sid) as session_count,
    ROUND(AVG(path_length), 2) as avg_path_length,
    ROUND(AVG(conversion_time), 2) as avg_conversion_time,
    ROUND(SUM(CASE WHEN is_direct_visit THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 4) as direct_visit_rate,
    ROUND(SUM(attribution_weight), 4) as attribution_weight_sum,
    device_type,
    platform
FROM dws_ecommerce_product_detail_attribution
WHERE dt='${hiveconf:dt}'
GROUP BY 
    product_id,
    entry_channel,
    entry_page_type,
    device_type,
    platform;
