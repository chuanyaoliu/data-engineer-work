-- ODS层ETL脚本
-- 描述: 从原始数据源抽取数据到ODS层
-- 执行时间: 每日凌晨2点

-- =============================================
-- ODS层点击日志ETL
-- =============================================
INSERT OVERWRITE TABLE ods_ecommerce_click_log 
PARTITION (dt='${hiveconf:dt}')
-- 仅保留带来页面跳转的点击：存在后续页面浏览，其referrer_url匹配该点击页面
WITH next_page_views AS (
    SELECT 
        pv.uid,
        pv.sid,
        pv.ts as pv_ts,
        pv.referrer_url
    FROM source_page_view_log pv
    WHERE pv.dt='${hiveconf:dt}'
),
nav_clicks AS (
    SELECT 
        c.*
    FROM source_click_log c
    JOIN next_page_views n
      ON c.uid = n.uid 
     AND c.sid = n.sid 
     AND n.referrer_url = c.page_url
     AND n.pv_ts >= c.ts
    WHERE c.dt='${hiveconf:dt}'
)
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
FROM nav_clicks
WHERE uid IS NOT NULL 
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
