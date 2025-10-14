-- ODS层ETL脚本
-- 描述: 从原始数据源抽取数据到ODS层
-- 执行时间: 每日凌晨2点

-- =============================================
-- ODS层点击日志ETL
-- =============================================
INSERT OVERWRITE TABLE ods_ecommerce_click_log 
PARTITION (dt='${hiveconf:dt}')
SELECT 
    uid,
    sid,
    ts,
    page_type,
    page_url,
    referrer_url,
    source_channel,
    device_type,
    platform,
    product_id,
    click_element,
    extra_info
FROM source_click_log
WHERE dt='${hiveconf:dt}'
  AND uid IS NOT NULL 
  AND sid IS NOT NULL
  AND ts IS NOT NULL;

-- =============================================
-- ODS层页面浏览日志ETL
-- =============================================
INSERT OVERWRITE TABLE ods_ecommerce_page_view_log 
PARTITION (dt='${hiveconf:dt}')
SELECT 
    uid,
    sid,
    ts,
    page_type,
    page_url,
    referrer_url,
    source_channel,
    device_type,
    platform,
    product_id,
    stay_duration,
    extra_info
FROM source_page_view_log
WHERE dt='${hiveconf:dt}'
  AND uid IS NOT NULL 
  AND sid IS NOT NULL
  AND ts IS NOT NULL;
