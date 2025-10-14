-- 集成测试用例
-- 描述: 电商商详页流量归因分析集成测试
-- 执行时间: 测试环境

-- =============================================
-- 测试用例1：数据一致性测试
-- =============================================
-- 测试目标：验证各层数据一致性
-- 预期结果：DWS层数据量与DWD层商详页访问量一致
WITH dwd_product_detail_count AS (
    SELECT COUNT(*) as dwd_count
    FROM dwd_ecommerce_user_behavior_path 
    WHERE dt='2024-01-01' AND is_product_detail = true
),
dws_attribution_count AS (
    SELECT COUNT(*) as dws_count
    FROM dws_ecommerce_product_detail_attribution 
    WHERE dt='2024-01-01'
)
SELECT 
    '测试用例1：数据一致性测试' as test_case,
    dwd_count as dwd_product_detail_count,
    dws_count as dws_attribution_count,
    CASE 
        WHEN dwd_count = dws_count THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dwd_product_detail_count, dws_attribution_count;

-- =============================================
-- 测试用例2：数据完整性测试
-- =============================================
-- 测试目标：验证数据完整性
-- 预期结果：所有商详页访问都有对应的归因记录
WITH product_detail_visits AS (
    SELECT DISTINCT uid, sid, product_id
    FROM dwd_ecommerce_user_behavior_path 
    WHERE dt='2024-01-01' AND is_product_detail = true
),
attribution_records AS (
    SELECT DISTINCT uid, sid, product_id
    FROM dws_ecommerce_product_detail_attribution 
    WHERE dt='2024-01-01'
)
SELECT 
    '测试用例2：数据完整性测试' as test_case,
    (SELECT COUNT(*) FROM product_detail_visits) as product_detail_count,
    (SELECT COUNT(*) FROM attribution_records) as attribution_count,
    (SELECT COUNT(*) FROM product_detail_visits p 
     LEFT JOIN attribution_records a ON p.uid = a.uid AND p.sid = a.sid AND p.product_id = a.product_id
     WHERE a.uid IS NULL) as missing_attribution_count,
    CASE 
        WHEN (SELECT COUNT(*) FROM product_detail_visits p 
              LEFT JOIN attribution_records a ON p.uid = a.uid AND p.sid = a.sid AND p.product_id = a.product_id
              WHERE a.uid IS NULL) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END as test_result;

-- =============================================
-- 测试用例3：入口渠道映射测试
-- =============================================
-- 测试目标：验证入口渠道映射正确性
-- 预期结果：入口渠道映射符合业务规则
SELECT 
    '测试用例3：入口渠道映射测试' as test_case,
    entry_channel,
    entry_page_type,
    COUNT(*) as count,
    CASE 
        WHEN entry_channel = 'homepage' AND entry_page_type = 'homepage' THEN 'PASS'
        WHEN entry_channel = 'search' AND entry_page_type = 'search_result' THEN 'PASS'
        WHEN entry_channel = 'recommend' AND entry_page_type = 'recommend_list' THEN 'PASS'
        WHEN entry_channel = 'direct' THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01'
GROUP BY entry_channel, entry_page_type;

-- =============================================
-- 测试用例4：路径长度计算测试
-- =============================================
-- 测试目标：验证路径长度计算正确性
-- 预期结果：路径长度与DWD层路径步骤一致
WITH dwd_path_length AS (
    SELECT 
        uid, 
        sid, 
        product_id,
        MAX(path_step) as max_path_step
    FROM dwd_ecommerce_user_behavior_path 
    WHERE dt='2024-01-01' AND is_product_detail = true
    GROUP BY uid, sid, product_id
),
dws_path_length AS (
    SELECT 
        uid, 
        sid, 
        product_id,
        path_length
    FROM dws_ecommerce_product_detail_attribution 
    WHERE dt='2024-01-01'
)
SELECT 
    '测试用例4：路径长度计算测试' as test_case,
    COUNT(*) as total_records,
    SUM(CASE WHEN d.max_path_step = w.path_length THEN 1 ELSE 0 END) as correct_length_count,
    CASE 
        WHEN SUM(CASE WHEN d.max_path_step = w.path_length THEN 1 ELSE 0 END) = COUNT(*) THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dwd_path_length d
JOIN dws_path_length w ON d.uid = w.uid AND d.sid = w.sid AND d.product_id = w.product_id;

-- =============================================
-- 测试用例5：转化时间计算测试
-- =============================================
-- 测试目标：验证转化时间计算正确性
-- 预期结果：转化时间 = 商详页时间戳 - 入口时间戳
SELECT 
    '测试用例5：转化时间计算测试' as test_case,
    COUNT(*) as total_records,
    SUM(CASE WHEN conversion_time = (product_detail_ts - entry_ts) / 1000 THEN 1 ELSE 0 END) as correct_time_count,
    CASE 
        WHEN SUM(CASE WHEN conversion_time = (product_detail_ts - entry_ts) / 1000 THEN 1 ELSE 0 END) = COUNT(*) THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dws_ecommerce_product_detail_attribution 
WHERE dt='2024-01-01';

-- =============================================
-- 测试用例6：设备类型一致性测试
-- =============================================
-- 测试目标：验证设备类型在各层保持一致
-- 预期结果：DWS层设备类型与DWD层一致
WITH dwd_device AS (
    SELECT DISTINCT uid, sid, device_type, platform
    FROM dwd_ecommerce_user_behavior_path 
    WHERE dt='2024-01-01' AND is_product_detail = true
),
dws_device AS (
    SELECT DISTINCT uid, sid, device_type, platform
    FROM dws_ecommerce_product_detail_attribution 
    WHERE dt='2024-01-01'
)
SELECT 
    '测试用例6：设备类型一致性测试' as test_case,
    COUNT(*) as total_records,
    SUM(CASE WHEN d.device_type = w.device_type AND d.platform = w.platform THEN 1 ELSE 0 END) as consistent_device_count,
    CASE 
        WHEN SUM(CASE WHEN d.device_type = w.device_type AND d.platform = w.platform THEN 1 ELSE 0 END) = COUNT(*) THEN 'PASS'
        ELSE 'FAIL'
    END as test_result
FROM dwd_device d
JOIN dws_device w ON d.uid = w.uid AND d.sid = w.sid;
