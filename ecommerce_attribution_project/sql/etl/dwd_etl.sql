-- DWD层ETL脚本
-- 描述: 清洗和整合用户行为数据，构建用户行为路径
-- 执行时间: 每日凌晨3点

-- =============================================
-- DWD层用户行为路径ETL
-- =============================================
INSERT OVERWRITE TABLE dwd_ecommerce_user_behavior_path 
PARTITION (dt='${hiveconf:dt}')
WITH user_behavior_union AS (
    -- 合并点击和浏览数据
    SELECT 
        uid,
        sid,
        ts,
        'click' as action_type,
        page_type,
        page_url,
        referrer_url,
        source_channel,
        device_type,
        platform,
        product_id,
        click_element,
        NULL as stay_duration,
        extra_info
    FROM ods_ecommerce_click_log
    WHERE dt='${hiveconf:dt}'
    
    UNION ALL
    
    SELECT 
        uid,
        sid,
        ts,
        'view' as action_type,
        page_type,
        page_url,
        referrer_url,
        source_channel,
        device_type,
        platform,
        product_id,
        NULL as click_element,
        stay_duration,
        extra_info
    FROM ods_ecommerce_page_view_log
    WHERE dt='${hiveconf:dt}'
),

-- 按用户会话排序，构建路径步骤
user_behavior_ranked AS (
    SELECT 
        uid,
        sid,
        ts,
        action_type,
        page_type,
        page_url,
        referrer_url,
        source_channel,
        device_type,
        platform,
        product_id,
        click_element,
        stay_duration,
        extra_info,
        ROW_NUMBER() OVER (PARTITION BY uid, sid ORDER BY ts) as path_step,
        CASE 
            WHEN page_type = 'product_detail' THEN true
            ELSE false
        END as is_product_detail
    FROM user_behavior_union
    WHERE uid IS NOT NULL 
      AND sid IS NOT NULL
      AND ts IS NOT NULL
)

SELECT 
    uid,
    sid,
    ts,
    action_type,
    page_type,
    page_url,
    referrer_url,
    source_channel,
    device_type,
    platform,
    product_id,
    click_element,
    stay_duration,
    path_step,
    is_product_detail,
    extra_info
FROM user_behavior_ranked;
