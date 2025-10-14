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
),

-- 使用栈式回退规则构建user_path
stack_based_path AS (
    SELECT 
        r.*,
        concat_ws('->',
          transform(
            aggregate(
              collect_list(named_struct('purl', r2.page_url, 'ptype', r2.page_type, 'rurl', r2.referrer_url))
              OVER (PARTITION BY r.uid, r.sid ORDER BY r2.ts
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
              array(),
              (stack, x) ->
                CASE 
                  WHEN size(stack) = 0 THEN array(x)
                  WHEN element_at(stack, size(stack)).purl = x.rurl THEN concat(stack, array(x))
                  ELSE 
                    CASE 
                      WHEN size(filter(stack, y -> y.purl = x.rurl)) > 0 THEN 
                        concat(
                          slice(
                            stack,
                            1,
                            array_position(transform(stack, y -> y.purl), x.rurl)
                          ),
                          array(x)
                        )
                      ELSE array(x)
                    END
                END,
              s -> s
            ),
            y -> y.ptype
          )
        ) as user_path
    FROM user_behavior_ranked r
    -- 关联自身用于窗口collect_list内引用
    JOIN user_behavior_ranked r2
      ON r.uid = r2.uid AND r.sid = r2.sid AND r2.ts <= r.ts
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
    user_path,
    extra_info
FROM stack_based_path;
