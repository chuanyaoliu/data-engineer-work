-- DWS层ETL脚本
-- 描述: 基于用户行为路径计算商详页流量归因
-- 执行时间: 每日凌晨4点

-- =============================================
-- DWS层商详页流量归因ETL
-- =============================================
INSERT OVERWRITE TABLE dws_ecommerce_product_detail_attribution 
PARTITION (dt='${hiveconf:dt}')
WITH user_sessions AS (
    -- 获取每个用户会话的完整路径
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
        user_path,
        extra_info
    FROM dwd_ecommerce_user_behavior_path
    WHERE dt='${hiveconf:dt}'
),

-- 识别商详页访问记录
product_detail_visits AS (
    SELECT 
        uid,
        sid,
        ts as product_detail_ts,
        product_id,
        device_type,
        platform,
        path_step as product_detail_step,
        user_path
    FROM user_sessions
    WHERE is_product_detail = true
),

-- 识别入口触点
entry_touchpoints AS (
    SELECT 
        uid,
        sid,
        ts as entry_ts,
        source_channel as entry_channel,
        page_type as entry_page_type,
        device_type,
        platform,
        path_step as entry_step,
        user_path,
        -- 定义入口渠道规则
        CASE 
            WHEN source_channel = 'homepage' AND page_type = 'marketing' THEN 'homepage_marketing'
            WHEN source_channel = 'search' AND page_type = 'search_result' THEN 'search_click'
            WHEN source_channel = 'recommend' AND page_type = 'recommend_list' THEN 'recommend_click'
            ELSE 'other'
        END as entry_type
    FROM user_sessions
    WHERE path_step = 1  -- 会话的第一个行为作为入口
),

-- 计算路径长度和转化时间
attribution_calculation AS (
    SELECT 
        pd.uid,
        pd.sid,
        pd.product_id,
        et.entry_channel,
        et.entry_page_type,
        et.entry_ts,
        pd.product_detail_ts,
        pd.product_detail_step as path_length,
        (pd.product_detail_ts - et.entry_ts) / 1000 as conversion_time,  -- 转换为秒
        CASE 
            WHEN pd.product_detail_step = 1 THEN true
            ELSE false
        END as is_direct_visit,
        -- 计算归因权重（基于路径长度和转化时间）
        CASE 
            WHEN pd.product_detail_step = 1 THEN 1.0
            WHEN pd.product_detail_step <= 3 THEN 0.8
            WHEN pd.product_detail_step <= 5 THEN 0.6
            ELSE 0.4
        END as attribution_weight,
        pd.device_type,
        pd.platform,
        CONCAT('entry_type:', et.entry_type, ';path_length:', pd.product_detail_step, ';user_path:', pd.user_path) as extra_attributes
    FROM product_detail_visits pd
    LEFT JOIN entry_touchpoints et 
        ON pd.uid = et.uid 
        AND pd.sid = et.sid
    WHERE et.entry_ts IS NOT NULL
)

SELECT 
    uid,
    sid,
    product_id,
    entry_channel,
    entry_page_type,
    entry_ts,
    product_detail_ts,
    path_length,
    conversion_time,
    is_direct_visit,
    attribution_weight,
    device_type,
    platform,
    extra_attributes
FROM attribution_calculation;
